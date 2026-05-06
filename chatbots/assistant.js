/* ═══════════════════════════════════════════
   SWX BOT — app.js
   Matches Flutter app functionality exactly
═══════════════════════════════════════════ */

// ── Config ────────────────────────────────
const GROQ_API_KEY = "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";
const SUPABASE_URL = "https://sbzoxwvuoidtywvkabmz.supabase.co";
const SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNiem94d3Z1b2lkdHl3dmthYm16Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzYxNDYzNTAsImV4cCI6MjA5MTcyMjM1MH0.IrfSKiuShXz0RA26fn5NFUS-VLk3mQAwJoSu28prju4";

const sb = window.supabase.createClient(SUPABASE_URL, SUPABASE_KEY);

const SYSTEM_PROMPT = `
You are Swx Bot — an intelligent support assistant.

Your role:
- Help users understand services, consultations, and treatments
- Answer FAQs clearly and concisely
- Guide users to book a consultation
- Build trust (medical, calm, professional tone)

Rules:
- Always answer based on provided FAQ data if available
- Do NOT act like a generic chatbot
- Do NOT give medical diagnosis
- Keep answers short, clear, and reassuring
- If unsure → guide user to consultation

Tone: Calm, professional, human-like. No hype, no marketing jargon.

Goal: Help the user understand and move toward booking a consultation.
If a question matches an FAQ → answer using that FAQ.
If not → answer briefly and suggest consultation.
`;

const RECO_MAP = {
    consultation: ["How are consultations conducted?", "Is consultation private?", "How do I book a consultation?"],
    treatment: ["What conditions do you treat?", "How long does treatment take?", "Is treatment personalised?"],
    safety: ["Is homoeopathy safe?", "Can children take treatment?", "Any side effects?"],
    default: ["What is Swx Bot?", "How does it work?", "How do I get started?"]
};

// ── State ─────────────────────────────────
let sessions = [];
let activeSession = null;
let drawerExpanded = false;
let _cachedFaqs = null;

// ── Settings ──────────────────────────────
const DEFAULTS = { theme: "dark", fontSize: "medium", bubble: "rounded", sound: false, typing: true, chips: true, pageSize: 5 };
let settings = { ...DEFAULTS, ...JSON.parse(localStorage.getItem("swxbot_settings") || "{}") };

function saveSettings() { localStorage.setItem("swxbot_settings", JSON.stringify(settings)); }

function applySettings() {
    document.body.classList.toggle("light", settings.theme === "light");
    document.body.classList.remove("font-small", "font-medium", "font-large");
    document.body.classList.add("font-" + settings.fontSize);
    document.body.classList.toggle("bubble-sharp", settings.bubble === "sharp");
}

// ── DOM refs ──────────────────────────────
const messagesEl = document.getElementById("messages");
const inputEl = document.getElementById("userInput");
const sendBtnEl = document.getElementById("sendBtn");
const recoBar = document.getElementById("recoBar");
const recoChipsEl = document.getElementById("recoChips");
const historyList = document.getElementById("historyList");
const chatShell = document.getElementById("chatShell");
const drawerHandle = document.getElementById("drawerHandle");
const mainScroll = document.getElementById("mainScroll");

// ── Helpers ───────────────────────────────
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

function playPop() {
    if (!settings.sound) return;
    try {
        const ctx = new (window.AudioContext || window.webkitAudioContext)();
        const osc = ctx.createOscillator();
        const gain = ctx.createGain();
        osc.connect(gain); gain.connect(ctx.destination);
        osc.frequency.setValueAtTime(880, ctx.currentTime);
        gain.gain.setValueAtTime(0.08, ctx.currentTime);
        gain.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + 0.18);
        osc.start(); osc.stop(ctx.currentTime + 0.18);
    } catch (_) { }
}

function renderMarkdown(text) {
    try {
        if (typeof marked !== "undefined") {
            marked.setOptions({ breaks: true, gfm: true });
            return marked.parse(text);
        }
    } catch (_) { }
    return text.replace(/\n/g, "<br>");
}

function getRecos(text) {
    const t = text.toLowerCase();
    if (t.includes("consult")) return RECO_MAP.consultation;
    if (t.includes("treat") || t.includes("condition")) return RECO_MAP.treatment;
    if (t.includes("safe") || t.includes("side")) return RECO_MAP.safety;
    return RECO_MAP.default;
}

// ── Drawer ────────────────────────────────
function expandDrawer() {
    drawerExpanded = true;
    chatShell.classList.add("expanded");
    mainScroll.classList.add("hidden");
}

function collapseDrawer() {
    drawerExpanded = false;
    chatShell.classList.remove("expanded");
    mainScroll.classList.remove("hidden");
}

function toggleDrawer() {
    drawerExpanded ? collapseDrawer() : expandDrawer();
}

drawerHandle.addEventListener("click", toggleDrawer);

// Drag handle
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
        const newH = Math.max(80, Math.min(chatShell.parentElement.offsetHeight, startH + delta));
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
        else drawerExpanded ? expandDrawer() : collapseDrawer();
        document.removeEventListener("mousemove", onMove);
        document.removeEventListener("touchmove", onMove);
        document.removeEventListener("mouseup", onEnd);
        document.removeEventListener("touchend", onEnd);
    }
    drawerHandle.addEventListener("mousedown", onStart);
    drawerHandle.addEventListener("touchstart", onStart, { passive: true });
})();

// ── Sessions ──────────────────────────────
function createSession() {
    const s = { id: Date.now(), label: "New conversation", history: [], messages: [] };
    sessions.unshift(s);
    activeSession = s;
    renderHistory();
    return s;
}

function renderHistory() {
    historyList.innerHTML = "";
    if (!sessions.length) {
        historyList.innerHTML = '<p class="history-empty">No conversations yet</p>';
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
            if (newName && newName.trim()) { s.label = newName.trim(); renderHistory(); }
        };

        const delBtn = document.createElement("button");
        delBtn.className = "hist-btn del";
        delBtn.title = "Delete";
        delBtn.innerHTML = '<i class="fa-solid fa-trash"></i>';
        delBtn.onclick = (e) => {
            e.stopPropagation();
            sessions = sessions.filter(x => x.id !== s.id);
            if (activeSession?.id === s.id) {
                if (sessions.length) loadSession(sessions[0]);
                else { startNewChat(); return; }
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

function loadSession(session) {
    activeSession = session;
    renderHistory();
    messagesEl.innerHTML = "";
    session.messages.forEach(m => appendMessage(m.role, m.text, false));
    messagesEl.scrollTop = messagesEl.scrollHeight;
    closeSidebar();
    if (session.messages.length > 0) expandDrawer();
}

function saveToSession(role, text) {
    if (!activeSession) return;
    activeSession.messages.push({ role, text, time: now() });
    if (role === "user" && activeSession.messages.filter(m => m.role === "user").length === 1) {
        activeSession.label = text.slice(0, 38) + (text.length > 38 ? "…" : "");
        renderHistory();
    }
}

// ── Message Rendering ─────────────────────
function appendMessage(role, text, animate = true) {
    const t = now();
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
    meta.innerHTML = `<span>${t}</span>`;

    if (role === "bot") {
        const copyBtn = document.createElement("button");
        copyBtn.className = "copy-btn";
        copyBtn.innerHTML = '<i class="fa-regular fa-copy"></i> Copy';
        copyBtn.onclick = () => {
            navigator.clipboard.writeText(text).then(() => showToast("Copied ✓"));
        };
        meta.appendChild(copyBtn);
        if (animate) playPop();
    }

    bodyWrap.appendChild(bubble);
    bodyWrap.appendChild(meta);
    row.appendChild(av);
    row.appendChild(bodyWrap);
    messagesEl.appendChild(row);
    messagesEl.scrollTop = messagesEl.scrollHeight;
    return row;
}

function showTypingIndicator() {
    if (!settings.typing) return;
    const row = document.createElement("div");
    row.className = "typing-row";
    row.id = "typingRow";
    const av = document.createElement("div");
    av.className = "msg-av";
    av.style.cssText = "background:linear-gradient(135deg,#4d7cff,#9a5cff);color:#fff;";
    av.textContent = "AI";
    const bubble = document.createElement("div");
    bubble.className = "typing-bubble";
    bubble.innerHTML = '<div class="typing-dots"><span></span><span></span><span></span></div>';
    row.appendChild(av);
    row.appendChild(bubble);
    messagesEl.appendChild(row);
    messagesEl.scrollTop = messagesEl.scrollHeight;
}

function removeTypingIndicator() {
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
    if (!settings.chips) return;
    const recs = getRecos(text);
    recoChipsEl.innerHTML = "";
    recs.forEach(r => {
        const chip = document.createElement("button");
        chip.className = "reco-chip";
        chip.textContent = r;
        chip.onclick = () => quickAsk(r);
        recoChipsEl.appendChild(chip);
    });
    recoBar.style.display = "block";
}

// ── FAQ ───────────────────────────────────
async function fetchFaqs() {
    if (_cachedFaqs) return _cachedFaqs;
    const { data, error } = await sb
        .from("faqs")
        .select("id, question, answer, category, sort_order")
        .order("sort_order", { ascending: true });
    if (error) { console.error("FAQ error:", error); return []; }
    _cachedFaqs = data || [];
    return _cachedFaqs;
}

function buildFaqContext(faqs) {
    return faqs.map(f => `Q: ${f.question}\nA: ${f.answer}`).join("\n\n");
}

function findDirectMatch(userText, faqs) {
    if (!faqs || !faqs.length) return null;
    const input = userText.toLowerCase();
    const words = input.split(" ").filter(w => w.length > 3);
    return faqs.find(f => {
        const q = f.question.toLowerCase();
        return words.some(w => q.includes(w));
    }) || null;
}

// ── Groq API ──────────────────────────────
async function askGroq(prompt, faqContext, history) {
    const trimmed = history.slice(-20);
    try {
        const response = await fetch("https://api.groq.com/openai/v1/chat/completions", {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
                "Authorization": "Bearer " + GROQ_API_KEY,
            },
            body: JSON.stringify({
                model: "llama-3.1-8b-instant",
                messages: [
                    { role: "system", content: SYSTEM_PROMPT + "\n\nFAQs:\n" + faqContext },
                    ...trimmed,
                    { role: "user", content: prompt }
                ],
                temperature: 0.7,
                max_tokens: 1024,
                stream: false,
            }),
        });
        const data = await response.json();
        if (data.choices && data.choices[0]) return data.choices[0].message.content;
        if (data.error) return `⚠️ API Error: ${data.error.message}`;
        return "No response received.";
    } catch (err) {
        console.error(err);
        return "⚠️ Connection failed. Please check your network and try again.";
    }
}

// ── Send ──────────────────────────────────
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
    showTypingIndicator();

    const faqs = await fetchFaqs();
    const faqContext = buildFaqContext(faqs);
    const matched = findDirectMatch(text, faqs);

    let reply;
    if (matched) {
        reply = matched.answer;
    } else {
        const history = activeSession?.history || [];
        history.push({ role: "user", content: text });
        reply = await askGroq(text, faqContext, history);
        history.push({ role: "assistant", content: reply });
        if (activeSession) activeSession.history = history;
    }

    removeTypingIndicator();
    appendMessage("bot", reply);
    saveToSession("bot", reply);
    showRecos(text);

    sendBtnEl.disabled = false;
    inputEl.focus();
}

function quickAsk(text) {
    inputEl.value = text;
    sendMessage();
}

// ── New Chat ──────────────────────────────
function startNewChat() {
    messagesEl.innerHTML = "";
    recoBar.style.display = "none";
    collapseDrawer();
    createSession();
    addDivider(new Date().toLocaleDateString([], { weekday: "long", month: "long", day: "numeric" }));
    appendMessage("bot", "Hello 👋 I'm Swx Bot.\nHow can I help you today?", false);
    inputEl.focus();
    closeSidebar();
}

// ── Export ────────────────────────────────
function exportChat() {
    if (!activeSession || !activeSession.messages.length) {
        showToast("Nothing to export yet.");
        return;
    }
    const lines = [
        "Swx Bot — Support Assistant",
        "=".repeat(50),
        `Date: ${new Date().toLocaleString()}`,
        ""
    ];
    activeSession.messages.forEach(m => {
        lines.push(`[${m.time}] ${m.role === "user" ? "You" : "Swx Bot"}:`);
        lines.push(m.text);
        lines.push("");
    });
    const blob = new Blob([lines.join("\n")], { type: "text/plain" });
    const a = document.createElement("a");
    a.href = URL.createObjectURL(blob);
    a.download = `swxbot-chat-${Date.now()}.txt`;
    a.click();
    showToast("Chat exported 📄");
}

// ── Search ────────────────────────────────
function toggleChatSearch() {
    const bar = document.getElementById("chatSearchBar");
    const inp = document.getElementById("chatSearchInput");
    bar.classList.toggle("open");
    if (bar.classList.contains("open")) inp.focus();
    else { inp.value = ""; searchChat(""); }
}

function searchChat(query) {
    const bubbles = messagesEl.querySelectorAll(".msg-bubble");
    bubbles.forEach(b => {
        const raw = b.dataset.raw || b.textContent;
        b.dataset.raw = raw;
        if (!query) { b.innerHTML = renderMarkdown(raw); return; }
        const safe = query.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
        b.innerHTML = renderMarkdown(raw).replace(new RegExp(`(${safe})`, "gi"), "<mark>$1</mark>");
    });
}

// ── Sidebar ───────────────────────────────
function openSidebar() {
    document.getElementById("sidebar").classList.add("open");
    document.getElementById("sidebarOverlay").classList.add("open");
}

function closeSidebar() {
    document.getElementById("sidebar").classList.remove("open");
    document.getElementById("sidebarOverlay").classList.remove("open");
}

// ── Quick Actions ─────────────────────────
function toggleQuickActions() {
    const items = document.getElementById("qaItems");
    const icon = document.getElementById("qaIcon");
    items.classList.toggle("open");
    icon.classList.toggle("open");
}

// ── Settings Modal ────────────────────────
function openSettings() {
    closeSidebar();
    syncSettingsUI();
    document.getElementById("settingsModal").classList.add("open");
}

function closeSettings() {
    document.getElementById("settingsModal").classList.remove("open");
}

function syncSettingsUI() {
    document.querySelectorAll("#themeToggle .tgl-opt").forEach(b => {
        b.classList.toggle("active", b.dataset.val === settings.theme);
    });
    document.querySelectorAll("#fontSizeToggle .tgl-opt").forEach(b => {
        b.classList.toggle("active", b.dataset.val === settings.fontSize);
    });
    document.querySelectorAll("#bubbleToggle .tgl-opt").forEach(b => {
        b.classList.toggle("active", b.dataset.val === settings.bubble);
    });
    document.getElementById("soundToggle").checked = settings.sound;
    document.getElementById("typingToggle").checked = settings.typing;
    document.getElementById("chipsToggle").checked = settings.chips;
    document.getElementById("pageSizeSelect").value = settings.pageSize;
}

function setSetting(key, value, btn = null) {
    settings[key] = value;
    saveSettings();
    applySettings();
    if (btn) {
        const group = btn.closest(".toggle-group");
        if (group) group.querySelectorAll(".tgl-opt").forEach(b => b.classList.toggle("active", b === btn));
    }
    if (key === "chips" && !value) recoBar.style.display = "none";
    showToast("Setting saved ✓");
}

function clearAllHistory() {
    if (!confirm("Delete all chat sessions? This cannot be undone.")) return;
    sessions = [];
    messagesEl.innerHTML = "";
    recoBar.style.display = "none";
    createSession();
    addDivider(new Date().toLocaleDateString([], { weekday: "long", month: "long", day: "numeric" }));
    appendMessage("bot", "Hello 👋 I'm Swx Bot.\nHow can I help you today?", false);
    collapseDrawer();
    renderHistory();
    closeSettings();
    showToast("All history cleared 🗑️");
}

// Close settings on backdrop click
document.getElementById("settingsModal").addEventListener("click", function (e) {
    if (e.target === this) closeSettings();
});

// ── Help Modal ────────────────────────────
function openHelp() {
    closeSidebar();
    document.getElementById("helpModal").classList.add("open");
}

function closeHelp() {
    document.getElementById("helpModal").classList.remove("open");
}

document.getElementById("helpModal").addEventListener("click", function (e) {
    if (e.target === this) closeHelp();
});

function toggleFaq(btn) {
    const ans = btn.nextElementSibling;
    const isOpen = ans.classList.contains("open");
    document.querySelectorAll(".faq-a").forEach(a => a.classList.remove("open"));
    document.querySelectorAll(".faq-q").forEach(b => b.classList.remove("open"));
    if (!isOpen) { ans.classList.add("open"); btn.classList.add("open"); }
}

function goBackWebsite() {
    window.location.href = "https://warriorhomeopath.com/";
}

// ── Keyboard Shortcuts ────────────────────
document.addEventListener("keydown", e => {
    const tag = document.activeElement.tagName;
    if (e.key === "Escape") {
        closeSidebar();
        closeSettings();
        closeHelp();
        const bar = document.getElementById("chatSearchBar");
        if (bar.classList.contains("open")) toggleChatSearch();
    }
    if ((e.ctrlKey || e.metaKey) && e.key === "k") { e.preventDefault(); toggleChatSearch(); }
    if ((e.ctrlKey || e.metaKey) && e.key === "n") { e.preventDefault(); startNewChat(); }
});

inputEl.addEventListener("keydown", e => {
    if (e.key === "Enter" && !e.shiftKey) { e.preventDefault(); sendMessage(); }
});

inputEl.addEventListener("focus", () => {
    if (!drawerExpanded) expandDrawer();
});

// ── Init ──────────────────────────────────
(function init() {
    applySettings();
    createSession();
    addDivider(new Date().toLocaleDateString([], { weekday: "long", month: "long", day: "numeric" }));
    appendMessage("bot", "Hello 👋 I'm Swx Bot.\nHow can I help you today?", false);
    inputEl.focus();
})();