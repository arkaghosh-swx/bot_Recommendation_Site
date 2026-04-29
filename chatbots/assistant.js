
const GROQ_API_KEY = "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";
var supabase = window.supabase.createClient(
    "https://sbzoxwvuoidtywvkabmz.supabase.co",
    "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNiem94d3Z1b2lkdHl3dmthYm16Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzYxNDYzNTAsImV4cCI6MjA5MTcyMjM1MH0.IrfSKiuShXz0RA26fn5NFUS-VLk3mQAwJoSu28prju4"
);

// const GROQ_API_KEY = "*********************************";
// var supabase = window.supabase.createClient(
//     "****************************************",
//     "*****************************************"
// );

/* assistant.js */
/* ============================================================
   Warrior Homoeopath AI Assistant — assistant.js
   Groq API · Llama 3 · Full-featured
============================================================ */

const SYSTEM_PROMPT = `
You are Sol — an intelligent assistant for Warrior Homoeopath.

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

Tone:
- Calm, professional, human-like
- No hype, no marketing jargon

Goal:
Help the user understand and move toward booking a consultation.

If a question matches an FAQ → answer using that FAQ.
If not → answer briefly and suggest consultation.
`;

// ── Recommendations map ───────────────────────────────────
const RECO_MAP = {
    consultation: [
        "How are consultations conducted?",
        "Is consultation private?",
        "How do I book a consultation?"
    ],
    treatment: [
        "What conditions do you treat?",
        "How long does treatment take?",
        "Is treatment personalised?"
    ],
    safety: [
        "Is homoeopathy safe?",
        "Can children take treatment?",
        "Any side effects?"
    ],
    default: [
        "What is Warrior Homoeopath?",
        "How does it work?",
        "How do I get started?"
    ]
};

function getRecos(text) {
    const t = text.toLowerCase();

    if (t.includes("consult")) return RECO_MAP.consultation;
    if (t.includes("treat") || t.includes("condition")) return RECO_MAP.treatment;
    if (t.includes("safe") || t.includes("side")) return RECO_MAP.safety;

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
function expandDrawer() {
    drawerExpanded = true;
    chatShell.classList.add("expanded");
}

function collapseDrawer() {
    drawerExpanded = false;
    chatShell.classList.remove("expanded");
}

function toggleDrawer() {
    if (drawerExpanded) {
        collapseDrawer();
    } else {
        expandDrawer();
    }
}

// Click handle to toggle
drawerHandle.addEventListener("click", toggleDrawer);

// Drag-to-expand on handle
(function initDrag() {
    let startY = 0;
    let startH = 0;
    let dragging = false;

    function onStart(e) {
        dragging = true;
        startY = e.touches ? e.touches[0].clientY : e.clientY;
        startH = chatShell.offsetHeight;
        // Disable transition during drag for snappy feel
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
        const delta = startY - clientY; // positive = dragging up
        const newH = Math.max(72, Math.min(chatShell.parentElement.offsetHeight, startH + delta));
        chatShell.style.height = newH + "px";
    }

    function onEnd(e) {
        if (!dragging) return;
        dragging = false;
        // Restore transition
        chatShell.style.transition = "";
        chatShell.style.height = "";

        // Snap: if dragged more than 80px up from peek, expand; else collapse
        const clientY = e.changedTouches ? e.changedTouches[0].clientY : e.clientY;
        const delta = startY - clientY;
        if (delta > 80) {
            expandDrawer();
        } else if (delta < -40) {
            collapseDrawer();
        } else {
            // Stay as is
            if (drawerExpanded) expandDrawer(); else collapseDrawer();
        }

        document.removeEventListener("mousemove", onMove);
        document.removeEventListener("touchmove", onMove);
        document.removeEventListener("mouseup", onEnd);
        document.removeEventListener("touchend", onEnd);
    }

    drawerHandle.addEventListener("mousedown", onStart);
    drawerHandle.addEventListener("touchstart", onStart, { passive: true });
})();

// ── Helpers ───────────────────────────────────────────────
async function getFAQContext() {
    const { data } = await supabase
        .from("faqs")
        .select("question, answer")
        .order("sort_order", { ascending: true });

    if (!data) return "";

    return data.map(f => `Q: ${f.question}\nA: ${f.answer}`).join("\n\n");
}

function checkFAQFirst(userText, faqs) {
    if (!faqs || !faqs.length) return null;

    const input = userText.toLowerCase();

    return faqs.find(f => {
        const q = f.question.toLowerCase();

        // keyword-based matching
        const words = input.split(" ");
        return words.some(w => w.length > 3 && q.includes(w));
    }) || null;
}

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

// ── Markdown render ───────────────────────────────────────
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

    if (role === "bot") {
        bubble.innerHTML = renderMarkdown(text);
    } else {
        bubble.textContent = text;
    }

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
    av.style.cssText = "background:linear-gradient(135deg,#4d7cff,#9a5cff);color:#fff;font-family:'Syne',sans-serif;font-weight:800;font-size:13px;width:32px;height:32px;border-radius:9px;display:flex;align-items:center;justify-content:center;flex-shrink:0;";

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
    const s = {
        id: Date.now(),
        label: "New conversation",
        history: [],
        messages: [],
    };
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
            if (newName && newName.trim()) {
                s.label = newName.trim();
                renderHistory();
            }
        };

        const delBtn = document.createElement("button");
        delBtn.className = "hist-btn del";
        delBtn.title = "Delete";
        delBtn.innerHTML = '<i class="fa-solid fa-trash"></i>';
        delBtn.onclick = (e) => {
            e.stopPropagation();
            sessions = sessions.filter(x => x.id !== s.id);
            if (activeSession?.id === s.id) {
                if (sessions.length) {
                    loadSession(sessions[0]);
                } else {
                    startNewChat();
                    return;
                }
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

// ── Groq API ──────────────────────────────────────────────
async function askGroq(prompt, faqContext) {
    conversationHistory.push({ role: "user", content: prompt });
    if (activeSession) activeSession.history = [...conversationHistory];

    const trimmed = conversationHistory.slice(-20);

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
                    {
                        role: "system",
                        content: SYSTEM_PROMPT + "\n\nFAQs:\n" + faqContext
                    },
                    ...trimmed
                ],
                temperature: 0.7,
                max_tokens: 1024,
                stream: false,
            }),
        });

        const data = await response.json();

        if (data.choices && data.choices[0]) {
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

    let reply = data.choices[0].message.content;

    // Add CTA if relevant
    if (prompt.toLowerCase().includes("consult")) {
        reply += "\n\n👉 You can book a consultation directly from our website.";
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

    // Expand drawer when user sends a message
    expandDrawer();

    appendMessage("user", text);
    saveToSession("user", text);
    showTyping();

    // Fetch FAQs once
    const { data: faqs, error } = await supabase
        .from("faqs")
        .select("*")
        .order("sort_order", { ascending: true });

    if (error) {
        console.error("FAQ fetch error:", error);
    }

    const faqContext = faqs
        ? faqs.map(f => `Q: ${f.question}\nA: ${f.answer}`).join("\n\n")
        : "";

    // Check for direct FAQ match
    const matchedFAQ = checkFAQFirst(text, faqs);

    let reply;

    if (matchedFAQ) {
        reply = matchedFAQ.answer;   // ✅ instant answer (no API call)
    } else {
        reply = await askGroq(text, faqContext); // 🤖 fallback to AI
    }
    removeTyping();

    appendMessage("bot", reply);
    saveToSession("bot", reply);
    showRecos(text);

    sendBtnEl.disabled = false;
    inputEl.focus();
}

// ── Quick ask ─────────────────────────────────────────────
function quickAsk(text) {
    inputEl.value = text;
    sendMessage();
}

// ── New chat ──────────────────────────────────────────────
function startNewChat() {
    messagesEl.innerHTML = "";
    recoBar.style.display = "none";
    conversationHistory = [];

    // Collapse drawer to show hero again
    collapseDrawer();

    createSession();
    addDivider("New conversation · " + new Date().toLocaleDateString([], { weekday: "short", month: "short", day: "numeric" }));
    appendMessage("bot", "Hello 👋 I'm Sol.\nHow can I help you with your health concerns or consultation?");
    inputEl.focus();
    document.getElementById("sidebar").classList.remove("open");
}

// ── Export chat ───────────────────────────────────────────
function exportChat() {
    if (!activeSession || !activeSession.messages.length) {
        showToast("Nothing to export yet.");
        return;
    }
    const lines = [
        "Sol — Warrior Homoeopath Assistant",
        "=".repeat(50),
        `Date: ${new Date().toLocaleString()}`,
        "",
    ];
    activeSession.messages.forEach(m => {
        lines.push(`[${m.time}] ${m.role === "user" ? "You" : "Assistant AI"}:`);
        lines.push(m.text);
        lines.push("");
    });
    const blob = new Blob([lines.join("\n")], { type: "text/plain" });
    const a = document.createElement("a");
    a.href = URL.createObjectURL(blob);
    a.download = `assistant-chat-${Date.now()}.txt`;
    a.click();
    showToast("Chat exported 📄");
}

// ── In-chat search ────────────────────────────────────────
function toggleChatSearch() {
    const bar = document.getElementById("chatSearchBar");
    const inp = document.getElementById("chatSearchInput");
    bar.classList.toggle("open");
    if (bar.classList.contains("open")) {
        inp.focus();
    } else {
        inp.value = "";
        searchChat("");
    }
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

// ── Context menu (attach) ─────────────────────────────────
function showContextMenu(btn) {
    const menu = document.getElementById("ctxMenu");
    const rect = btn.getBoundingClientRect();
    menu.style.left = rect.left + "px";
    menu.style.top = (rect.top - menu.offsetHeight - 8) + "px";
    menu.classList.toggle("open");
}

function closeCtx() {
    document.getElementById("ctxMenu").classList.remove("open");
}

document.addEventListener("click", e => {
    const menu = document.getElementById("ctxMenu");
    if (!menu.contains(e.target) && !e.target.closest(".composer-attach")) {
        menu.classList.remove("open");
    }
});

// ── Sidebar (mobile) ──────────────────────────────────────
function toggleSidebar() {
    document.getElementById("sidebar").classList.toggle("open");
}

// ── Quick Actions Toggle ──────────────────────────────────
function toggleQuickActions() {
    const section = document.getElementById("quickActionsSection");
    const container = document.getElementById("quickNavContainer");
    section.classList.toggle("expanded");
    container.classList.toggle("show");
}

// ── Keyboard shortcuts ────────────────────────────────────
document.addEventListener("keydown", e => {
    if (e.key === "Escape") {
        document.getElementById("sidebar").classList.remove("open");
        document.getElementById("chatSearchBar").classList.remove("open");
        collapseDrawer();
    }
    if ((e.ctrlKey || e.metaKey) && e.key === "k") {
        e.preventDefault();
        toggleChatSearch();
    }
    if ((e.ctrlKey || e.metaKey) && e.key === "n") {
        e.preventDefault();
        startNewChat();
    }
});

inputEl.addEventListener("keydown", e => {
    if (e.key === "Enter" && !e.shiftKey) {
        e.preventDefault();
        sendMessage();
    }
});

// Also expand drawer when user focuses the input
inputEl.addEventListener("focus", () => {
    if (!drawerExpanded) expandDrawer();
});

// ── Init ──────────────────────────────────────────────────
(function init() {
    createSession();
    addDivider(new Date().toLocaleDateString([], { weekday: "long", month: "long", day: "numeric" }));
    appendMessage("bot", "Hello 👋 I'm Sol.\nHow can I help you with your health concerns or consultation?", false);
    inputEl.focus();
})();