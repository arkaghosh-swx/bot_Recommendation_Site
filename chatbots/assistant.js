/* ============================================================
   Solworxs AI Assistant — assistant.js
   Calls /api/chat proxy → GROQ_API_KEY stays secret on server
============================================================ */

// ── NO API KEY HERE — lives in .env on your server ────────

const SYSTEM_PROMPT = `You are the Assistant AI  — a sharp, high-performance growth advisor for businesses. You help with:
- Business growth strategies and go-to-market plans
- Pricing, plans, and ROI analysis
- Lead generation and marketing automation
- Booking product demos
- Capturing lead/contact details
- Explaining Assistant services

Be concise, confident, and professional. Use markdown formatting — headers, bullet lists, bold text, tables — where it adds clarity. Never be vague. When a user wants to book a demo or share contact info, collect: Name, Email, Company, and their main goal.`;

// ── Recommendations map ───────────────────────────────────
const RECO_MAP = {
    pricing: ["Compare all plans", "What's included in Pro?", "Do you offer a free trial?"],
    growth: ["Suggest a 90-day plan", "What's your biggest case study?", "How fast can I see ROI?"],
    demo: ["What happens after I book?", "Who will I speak with?", "Can I see a live dashboard?"],
    leads: ["How does lead scoring work?", "Integrate with my CRM?", "Show an automation example"],
    automation: ["What can you automate?", "Connect to Zapier?", "Email automation examples"],
    default: ["How can you help my business?", "What does Assistant do?", "Tell me about pricing"],
};

function getRecos(text) {
    const t = text.toLowerCase();
    if (t.includes("pric") || t.includes("cost") || t.includes("plan")) return RECO_MAP.pricing;
    if (t.includes("grow") || t.includes("scale") || t.includes("revenue")) return RECO_MAP.growth;
    if (t.includes("demo") || t.includes("book") || t.includes("schedule")) return RECO_MAP.demo;
    if (t.includes("lead") || t.includes("contact") || t.includes("capture")) return RECO_MAP.leads;
    if (t.includes("automat") || t.includes("workflow") || t.includes("zapier")) return RECO_MAP.automation;
    return RECO_MAP.default;
}

// ── State ─────────────────────────────────────────────────
let conversationHistory = [];
let sessions = [];
let activeSession = null;
let drawerExpanded = false;

// ── DOM refs ──────────────────────────────────────────────
const messagesEl = document.getElementById("messages");
const inputEl = document.getElementById("userInput");
const sendBtnEl = document.getElementById("sendBtn");
const recoBar = document.getElementById("recoBar");
const recoChips = document.getElementById("recoChips");
const historyList = document.getElementById("historyList");
const chatShell = document.getElementById("chatShell");
const drawerHandle = document.getElementById("drawerHandle");

// ── Drawer logic ──────────────────────────────────────────
function expandDrawer() { drawerExpanded = true; chatShell.classList.add("expanded"); }
function collapseDrawer() { drawerExpanded = false; chatShell.classList.remove("expanded"); }
function toggleDrawer() { drawerExpanded ? collapseDrawer() : expandDrawer(); }

drawerHandle.addEventListener("click", toggleDrawer);

// Drag-to-expand
(function initDrag() {
    let startY = 0, startH = 0, dragging = false;

    function onStart(e) {
        dragging = true;
        startY = e.touches ? e.touches[0].clientY : e.clientY;
        startH = chatShell.offsetHeight;
        chatShell.style.transition = "none";
        document.addEventListener("mousemove", onMove);
        document.addEventListener("touchmove", onMove, { passive: false });
        document.addEventListener("mouseup", onEnd);
        document.addEventListener("touchend", onEnd);
    }

    function onMove(e) {
        if (!dragging) return;
        if (e.cancelable) e.preventDefault();
        const clientY = e.touches ? e.touches[0].clientY : e.clientY;
        const delta = startY - clientY;
        const newH = Math.max(72, Math.min(chatShell.parentElement.offsetHeight, startH + delta));
        chatShell.style.height = newH + "px";
    }

    function onEnd(e) {
        if (!dragging) return;
        dragging = false;
        chatShell.style.transition = "";
        chatShell.style.height = "";
        const clientY = e.changedTouches ? e.changedTouches[0].clientY : e.clientY;
        const delta = startY - clientY;
        if (delta > 80) expandDrawer();
        else if (delta < -40) collapseDrawer();
        else { if (drawerExpanded) expandDrawer(); else collapseDrawer(); }
        document.removeEventListener("mousemove", onMove);
        document.removeEventListener("touchmove", onMove);
        document.removeEventListener("mouseup", onEnd);
        document.removeEventListener("touchend", onEnd);
    }

    drawerHandle.addEventListener("mousedown", onStart);
    drawerHandle.addEventListener("touchstart", onStart, { passive: true });
})();

// ── Helpers ───────────────────────────────────────────────
function now() {
    return new Date().toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" });
}

function showToast(msg, ms = 2600) {
    const t = document.getElementById("toast");
    t.textContent = msg;
    t.classList.add("show");
    setTimeout(() => t.classList.remove("show"), ms);
}

function autoResize(el) {
    el.style.height = "auto";
    el.style.height = Math.min(el.scrollHeight, 140) + "px";
}

// ── Markdown ──────────────────────────────────────────────
function fallbackMarkdown(text) {
    return text
        .replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;")
        .replace(/```([\s\S]*?)```/g, '<pre><code>$1</code></pre>')
        .replace(/`([^`]+)`/g, '<code>$1</code>')
        .replace(/^### (.+)$/gm, '<h3>$1</h3>')
        .replace(/^## (.+)$/gm, '<h2>$1</h2>')
        .replace(/^# (.+)$/gm, '<h1>$1</h1>')
        .replace(/\*\*(.+?)\*\*/g, '<strong>$1</strong>')
        .replace(/\*(.+?)\*/g, '<em>$1</em>')
        .replace(/^[\-\*] (.+)$/gm, '<li>$1</li>')
        .replace(/(<li>[\s\S]+?<\/li>)/g, '<ul>$1</ul>')
        .replace(/\n/g, '<br>');
}

function renderMarkdown(text) {
    try {
        if (typeof marked !== "undefined") {
            marked.setOptions({ breaks: true, gfm: true });
            return marked.parse(text);
        }
    } catch (_) { }
    return fallbackMarkdown(text);
}

// ── Message rendering ─────────────────────────────────────
function appendMessage(role, text, animate = true) {
    const row = document.createElement("div");
    row.className = `msg-row ${role}`;
    if (!animate) { row.style.animation = "none"; row.style.opacity = "1"; }

    const av = document.createElement("div");
    av.className = "msg-av";
    av.textContent = role === "bot" ? "AI" : "U";

    const bodyWrap = document.createElement("div");
    bodyWrap.className = "msg-body-wrap";

    const bubble = document.createElement("div");
    bubble.className = "msg-bubble";
    if (role === "bot") bubble.innerHTML = renderMarkdown(text);
    else bubble.textContent = text;

    const meta = document.createElement("div");
    meta.className = "msg-meta";
    meta.innerHTML = `<span>${now()}</span>`;

    if (role === "bot") {
        const copyBtn = document.createElement("button");
        copyBtn.className = "copy-btn";
        copyBtn.innerHTML = '<i class="fa-regular fa-copy"></i> Copy';
        copyBtn.onclick = () => navigator.clipboard.writeText(text).then(() => showToast("Copied ✓"));
        meta.appendChild(copyBtn);
    }

    bodyWrap.appendChild(bubble);
    bodyWrap.appendChild(meta);
    row.appendChild(av);
    row.appendChild(bodyWrap);
    messagesEl.appendChild(row);
    messagesEl.scrollTop = messagesEl.scrollHeight;
    return row;
}

function showTyping() {
    const row = document.createElement("div");
    row.className = "typing-row";
    row.id = "typingRow";
    const av = document.createElement("div");
    av.className = "msg-av";
    av.textContent = "AI";
    av.style.cssText = "background:linear-gradient(135deg,#1d4ed8,#3b82f6);color:#fff;font-family:'Syne',sans-serif;font-weight:800;font-size:13px;width:32px;height:32px;border-radius:9px;display:flex;align-items:center;justify-content:center;flex-shrink:0;";
    const bubble = document.createElement("div");
    bubble.className = "typing-bubble";
    bubble.innerHTML = '<div class="typing-dots"><span></span><span></span><span></span></div>';
    row.appendChild(av);
    row.appendChild(bubble);
    messagesEl.appendChild(row);
    messagesEl.scrollTop = messagesEl.scrollHeight;
}

function removeTyping() {
    const el = document.getElementById("typingRow");
    if (el) el.remove();
}

function addDivider(label) {
    const d = document.createElement("div");
    d.className = "chat-divider";
    d.textContent = label;
    messagesEl.appendChild(d);
}

function showRecos(text) {
    const recs = getRecos(text);
    recoChips.innerHTML = "";
    recs.forEach(r => {
        const chip = document.createElement("button");
        chip.className = "reco-chip";
        chip.textContent = r;
        chip.onclick = () => quickAsk(r);
        recoChips.appendChild(chip);
    });
    recoBar.style.display = "flex";
}

// ── Sessions ──────────────────────────────────────────────
function createSession() {
    const s = { id: Date.now(), label: "New conversation", history: [], messages: [] };
    sessions.unshift(s);
    activeSession = s;
    conversationHistory = [];
    renderHistory();
    return s;
}

function renderHistory() {
    historyList.innerHTML = "";
    if (!sessions.length) {
        historyList.innerHTML = '<p class="history-empty">Start a conversation to<br>build your history.</p>';
        return;
    }
    sessions.forEach(s => {
        const el = document.createElement("div");
        el.className = "history-item" + (s.id === activeSession?.id ? " active" : "");

        const label = document.createElement("span");
        label.className = "hist-label";
        label.textContent = s.label;
        label.title = s.label;
        label.onclick = () => loadSession(s);

        const actions = document.createElement("div");
        actions.className = "hist-actions";

        const renameBtn = document.createElement("button");
        renameBtn.className = "hist-btn";
        renameBtn.title = "Rename";
        renameBtn.innerHTML = '<i class="fa-solid fa-pen-to-square"></i>';
        renameBtn.onclick = (e) => {
            e.stopPropagation();
            const newName = prompt("Rename conversation:", s.label);
            if (newName?.trim()) { s.label = newName.trim(); renderHistory(); }
        };

        const delBtn = document.createElement("button");
        delBtn.className = "hist-btn del";
        delBtn.title = "Delete";
        delBtn.innerHTML = '<i class="fa-solid fa-trash"></i>';
        delBtn.onclick = (e) => {
            e.stopPropagation();
            sessions = sessions.filter(x => x.id !== s.id);
            if (activeSession?.id === s.id) {
                sessions.length ? loadSession(sessions[0]) : startNewChat();
                return;
            }
            renderHistory();
        };

        actions.appendChild(renameBtn);
        actions.appendChild(delBtn);
        el.appendChild(label);
        el.appendChild(actions);
        historyList.appendChild(el);
    });
}

function clearAllSessions() {
    if (!confirm("Delete all conversation history?")) return;
    sessions = [];
    startNewChat();
    showToast("History cleared 🗑️");
}

function loadSession(session) {
    activeSession = session;
    conversationHistory = [...session.history];
    renderHistory();
    messagesEl.innerHTML = "";
    session.messages.forEach(m => appendMessage(m.role, m.text, false));
    messagesEl.scrollTop = messagesEl.scrollHeight;
    document.getElementById("sidebar").classList.remove("open");
}

function saveToSession(role, text) {
    if (!activeSession) return;
    activeSession.messages.push({ role, text, time: now() });
    if (role === "user" && activeSession.messages.filter(m => m.role === "user").length === 1) {
        activeSession.label = text.slice(0, 38) + (text.length > 38 ? "…" : "");
        renderHistory();
    }
}

// ── API call → /api/chat proxy (key never touches browser) ─
async function askGroq(prompt) {
    conversationHistory.push({ role: "user", content: prompt });
    if (activeSession) activeSession.history = [...conversationHistory];

    try {
        const response = await fetch("/api/chat", {    // ← YOUR server, not Groq directly
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
                model: "llama-3.1-8b-instant",
                messages: [
                    { role: "system", content: SYSTEM_PROMPT },
                    ...conversationHistory.slice(-20),
                ],
                temperature: 0.7,
                max_tokens: 1024,
                stream: false,
            }),
        });

        const data = await response.json();

        if (data.choices?.[0]) {
            const reply = data.choices[0].message.content;
            conversationHistory.push({ role: "assistant", content: reply });
            if (activeSession) activeSession.history = [...conversationHistory];
            return reply;
        }

        if (data.error) return `⚠️ API Error: ${data.error.message}`;
        return "No response received.";

    } catch (err) {
        console.error(err);
        return "⚠️ Connection failed. Please check your network and try again.";
    }
}

// ── Send ──────────────────────────────────────────────────
async function sendMessage() {
    const text = inputEl.value.trim();
    if (!text) return;
    inputEl.value = "";
    inputEl.style.height = "auto";
    sendBtnEl.disabled = true;
    recoBar.style.display = "none";
    expandDrawer();
    appendMessage("user", text);
    saveToSession("user", text);
    showTyping();
    const reply = await askGroq(text);
    removeTyping();
    appendMessage("bot", reply);
    saveToSession("bot", reply);
    showRecos(text);
    sendBtnEl.disabled = false;
    inputEl.focus();
}

function quickAsk(text) { inputEl.value = text; sendMessage(); }

// ── New chat ──────────────────────────────────────────────
function startNewChat() {
    messagesEl.innerHTML = "";
    recoBar.style.display = "none";
    conversationHistory = [];
    collapseDrawer();
    createSession();
    addDivider("New conversation · " + new Date().toLocaleDateString([], { weekday: "short", month: "short", day: "numeric" }));
    appendMessage("bot", "Hello 👋 I'm your Swx AI.\nTell me about your business goals and I'll guide you to the right solution.");
    inputEl.focus();
    document.getElementById("sidebar").classList.remove("open");
}

// ── Export ────────────────────────────────────────────────
function exportChat() {
    if (!activeSession?.messages.length) { showToast("Nothing to export yet."); return; }
    const lines = ["Swx AI Chat Export", "=".repeat(50), `Date: ${new Date().toLocaleString()}`, ""];
    activeSession.messages.forEach(m => {
        lines.push(`[${m.time}] ${m.role === "user" ? "You" : "Swx AI"}:`);
        lines.push(m.text);
        lines.push("");
    });
    const a = document.createElement("a");
    a.href = URL.createObjectURL(new Blob([lines.join("\n")], { type: "text/plain" }));
    a.download = `swx-chat-${Date.now()}.txt`;
    a.click();
    showToast("Chat exported 📄");
}

// ── Search ────────────────────────────────────────────────
function toggleChatSearch() {
    const bar = document.getElementById("chatSearchBar");
    const inp = document.getElementById("chatSearchInput");
    bar.classList.toggle("open");
    if (bar.classList.contains("open")) inp.focus();
    else { inp.value = ""; searchChat(""); }
}

function searchChat(query) {
    messagesEl.querySelectorAll(".msg-bubble").forEach(b => {
        const raw = b.dataset.raw || b.textContent;
        b.dataset.raw = raw;
        if (!query) { b.innerHTML = renderMarkdown(raw); return; }
        const safe = query.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
        b.innerHTML = renderMarkdown(raw).replace(new RegExp(`(${safe})`, "gi"), "<mark>$1</mark>");
    });
}

// ── Context menu ──────────────────────────────────────────
function showContextMenu(btn) {
    const menu = document.getElementById("ctxMenu");
    const rect = btn.getBoundingClientRect();
    menu.style.left = rect.left + "px";
    menu.style.top = (rect.top - menu.offsetHeight - 8) + "px";
    menu.classList.toggle("open");
}
function closeCtx() { document.getElementById("ctxMenu").classList.remove("open"); }
document.addEventListener("click", e => {
    const menu = document.getElementById("ctxMenu");
    if (!menu.contains(e.target) && !e.target.closest(".composer-attach")) menu.classList.remove("open");
});

// ── Sidebar ───────────────────────────────────────────────
function toggleSidebar() { document.getElementById("sidebar").classList.toggle("open"); }

// ── Quick Actions ─────────────────────────────────────────
function toggleQuickActions() {
    document.getElementById("quickActionsSection").classList.toggle("expanded");
    document.getElementById("quickNavContainer").classList.toggle("show");
}

// ── Keyboard shortcuts ────────────────────────────────────
document.addEventListener("keydown", e => {
    if (e.key === "Escape") {
        document.getElementById("sidebar").classList.remove("open");
        document.getElementById("chatSearchBar").classList.remove("open");
        collapseDrawer();
    }
    if ((e.ctrlKey || e.metaKey) && e.key === "k") { e.preventDefault(); toggleChatSearch(); }
    if ((e.ctrlKey || e.metaKey) && e.key === "n") { e.preventDefault(); startNewChat(); }
});

inputEl.addEventListener("keydown", e => {
    if (e.key === "Enter" && !e.shiftKey) { e.preventDefault(); sendMessage(); }
});
inputEl.addEventListener("focus", () => { if (!drawerExpanded) expandDrawer(); });

// ── Init ──────────────────────────────────────────────────
(function init() {
    createSession();
    addDivider(new Date().toLocaleDateString([], { weekday: "long", month: "long", day: "numeric" }));
    appendMessage("bot", "Hello 👋 I'm your Swx AI.\nTell me about your business goals and I'll guide you to the right solution.", false);
    inputEl.focus();
})();