/* ─────────────────────────────────────────
   SOLWORXS · BOT CHOOSER · SCRIPT.JS
───────────────────────────────────────── */
/* ══════════════════════════════════════════
   CANVAS PARTICLES (inside modal)
══════════════════════════════════════════ */
const canvas = document.getElementById("modalCanvas");
const ctx = canvas.getContext("2d");
let particles = [];
let rafId;

const supabase = window.supabase.createClient(
    'https://sbzoxwvuoidtywvkabmz.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNiem94d3Z1b2lkdHl3dmthYm16Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzYxNDYzNTAsImV4cCI6MjA5MTcyMjM1MH0.IrfSKiuShXz0RA26fn5NFUS-VLk3mQAwJoSu28prju4'
);

async function fetchFAQs() {
    const { data, error } = await supabase
        .from('faqs')
        .select('*')
        .eq('is_active', true)
        .order('order_index', { ascending: true });

    if (error) {
        console.error("FAQ fetch error:", error);
        return [];
    }
    console.log("FAQs:", faqs);
    return data;
}
function resizeCanvas() {
    canvas.width = window.innerWidth;
    canvas.height = window.innerHeight;
}
resizeCanvas();
window.addEventListener("resize", resizeCanvas);

function spawnParticle() {
    return {
        x: Math.random() * canvas.width,
        y: Math.random() * canvas.height,
        r: Math.random() * 1.8 + 0.4,
        vx: (Math.random() - 0.5) * 0.3,
        vy: (Math.random() - 0.5) * 0.3 - 0.15,
        life: 1,
        decay: Math.random() * 0.003 + 0.001,
        color: Math.random() > 0.5 ? "59,130,246" : "34,197,94"
    };
}

for (let i = 0; i < 120; i++) particles.push(spawnParticle());

function drawParticles() {
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    particles.forEach((p, i) => {
        p.x += p.vx;
        p.y += p.vy;
        p.life -= p.decay;
        if (p.life <= 0) particles[i] = spawnParticle();
        ctx.beginPath();
        ctx.arc(p.x, p.y, p.r, 0, Math.PI * 2);
        ctx.fillStyle = `rgba(${p.color},${p.life * 0.7})`;
        ctx.fill();
    });
    rafId = requestAnimationFrame(drawParticles);
}
drawParticles();

/* ══════════════════════════════════════════
   BOT DATA
══════════════════════════════════════════ */
const BOT_DATA = {
    whatsapp: {
        title: "WhatsApp Bot",
        desc: "WhatsApp is massive in India. Reach your customers where they already are.",
        icon: "fa-brands fa-whatsapp",
        theme: "wa-theme",
        ctaText: "Open on WhatsApp",
        ctaIcon: "fa-brands fa-whatsapp",
        ctaHref: "https://wa.me/15551688355?text=Hi%20Solworxs!",
        features: [
            "Instant Customer Replies",
            "Auto Lead Collection",
            "Order Status Updates",
            "24/7 WhatsApp Support",
            "Higher Conversion Rate",
            "Broadcast Messaging",
        ],
        agentQuip: "📲 WhatsApp Bot is 🔥 in India!",
        cardId: "cardWhatsapp",
        badgeId: "badgeWhatsapp",
    },
    ai: {
        title: "AI Assistant Bot",
        desc: "Enterprise-grade AI that automates conversations, captures leads, and books demos.",
        icon: "fa-solid fa-robot",
        theme: "ai-theme",
        ctaText: "Launch AI Bot",
        ctaIcon: "fa-solid fa-robot",
        ctaHref: "chatbots/assistant.html",
        features: [
            "Instant Smart Replies",
            "Lead Capture Flow",
            "Automated Follow-up",
            "Conversion Analytics",
            "Demo Booking Support",
            "Multi-channel Ready",
        ],
        agentQuip: "🤖 AI Bot is your best enterprise pick!",
        cardId: "cardAI",
        badgeId: "badgeAI",
    }
};

/* ══════════════════════════════════════════
   MODAL ELEMENTS
══════════════════════════════════════════ */
const modalOverlay = document.getElementById("modalOverlay");
const modalCard = document.getElementById("modalCard");
const modalLocation = document.getElementById("modalLocation");
const modalBotIcon = document.getElementById("modalBotIcon");
const modalIcon = document.getElementById("modalIcon");
const modalTitle = document.getElementById("modalTitle");
const modalDesc = document.getElementById("modalDesc");
const modalFeatures = document.getElementById("modalFeatures");
const modalCTA = document.getElementById("modalCTA");
const modalCTAIcon = document.getElementById("modalCTAIcon");
const modalCTAText = document.getElementById("modalCTAText");
const modalDecline = document.getElementById("modalDecline");
const pageWrap = document.getElementById("pageWrap");
const locationLine = document.getElementById("locationLine");

/* ── Populate modal with bot data ── */
function populateModal(botKey, locationStr) {
    const bot = BOT_DATA[botKey];

    // Theme colours
    modalCard.classList.remove("wa-theme", "ai-theme");
    modalCard.classList.add(bot.theme);
    modalBotIcon.classList.remove("wa-theme", "ai-theme");
    modalBotIcon.classList.add(bot.theme);

    // Location pill
    modalLocation.textContent = locationStr;

    // Icon
    modalIcon.className = bot.icon;

    // Title + desc
    modalTitle.textContent = bot.title;
    modalDesc.textContent = bot.desc;

    // Features (2-column grid)
    modalFeatures.innerHTML = "";
    modalFeatures.classList.remove("wa-theme", "ai-theme");
    modalFeatures.classList.add(bot.theme);
    bot.features.forEach(f => {
        const li = document.createElement("li");
        li.innerHTML = `<i class="fa-solid fa-circle-check"></i> ${f}`;
        modalFeatures.appendChild(li);
    });

    // CTA button
    modalCTAIcon.className = bot.ctaIcon;
    modalCTAText.textContent = bot.ctaText;
    modalCTA.href = bot.ctaHref;
    modalCTA.classList.remove("wa-theme", "ai-theme");
    modalCTA.classList.add(bot.theme);
}

/* ── Close modal → reveal page ── */
function closeModal(recommendedKey) {
    // Stop particles
    cancelAnimationFrame(rafId);
    ctx.clearRect(0, 0, canvas.width, canvas.height);

    modalOverlay.classList.add("hidden");

    // Show page
    pageWrap.classList.add("visible");

    // Highlight the recommended card on the page (subtle)
    if (recommendedKey) {
        const card = document.getElementById(BOT_DATA[recommendedKey].cardId);
        const badge = document.getElementById(BOT_DATA[recommendedKey].badgeId);
        card.classList.add("highlighted");
        badge.style.display = "inline-flex";
        // Scroll to cards smoothly
        setTimeout(() => {
            document.querySelector(".cards-section").scrollIntoView({ behavior: "smooth" });
        }, 400);
    }

    // Start Sol's roaming
    startRoaming();
}

/* ── "Not for me" ── */
modalDecline.addEventListener("click", () => {
    agentSay("🤔 No worries! Pick from both!");
    closeModal(currentRecommendedKey);
});

/* ── User clicks CTA (accept) ── */
modalCTA.addEventListener("click", () => {
    agentSay("🎉 Great pick! Enjoy the bot!");
    // Let the href do its job; also close modal in background
    setTimeout(() => closeModal(null), 300);
});

/* ══════════════════════════════════════════
   GEO DETECTION
══════════════════════════════════════════ */
let currentRecommendedKey = "ai";   // default

async function detectAndRecommend() {
    try {
        const res = await fetch("https://api.db-ip.com/v2/free/self");
        const data = await res.json();

        const country = (data.countryCode || "").toUpperCase();
        const countryName = data.countryName || "your region";
        const city = data.city || "";
        const locStr = city ? `${city}, ${countryName}` : countryName;

        locationLine.textContent = `📍 ${locStr}`;

        // India → WhatsApp; elsewhere → AI
        currentRecommendedKey = country === "IN" ? "whatsapp" : "ai";
        // // original
        // currentRecommendedKey = "ai";  
        // // TEMP: force outside-India for testing

        populateModal(currentRecommendedKey, `📍 ${locStr}`);

        // Update agent quip
        agentLines[2] = BOT_DATA[currentRecommendedKey].agentQuip;

    } catch (err) {
        console.warn("Geo failed:", err);
        locationLine.textContent = "📍 Region detection unavailable";
        populateModal("ai", "📍 Global");
    }
}

/* ══════════════════════════════════════════
   CONSENT BANNER — gates geo fetch
══════════════════════════════════════════ */

/* agentSay defined early so consent handlers can call it */
const agentMsgEl = document.getElementById("agentMsg");
agentMsgEl.style.transition = "opacity .3s ease";
function agentSay(text) {
    agentMsgEl.style.opacity = "0";
    setTimeout(() => {
        agentMsgEl.textContent = text;
        agentMsgEl.style.opacity = "1";
    }, 250);
}

const consentBanner = document.getElementById("consentBanner");
const consentBackdrop = document.getElementById("consentBackdrop");
const consentAccept = document.getElementById("consentAccept");
const consentDeclineBtn = document.getElementById("consentDeclineBtn");
const consentLearnMore = document.getElementById("consentLearnMore");
const consentDetail = document.getElementById("consentDetail");

const CONSENT_KEY = "solworxs_geo_consent";

function showConsent() {
    // Slide up after short delay so page renders first
    setTimeout(() => {
        consentBackdrop.classList.add("active");
        consentBanner.classList.add("active");
    }, 600);
}

function hideConsent() {
    consentBanner.classList.add("gone");
    consentBackdrop.classList.remove("active");
    setTimeout(() => consentBanner.remove(), 500);
}

// "Learn more" toggles expanded detail
consentLearnMore.addEventListener("click", (e) => {
    e.preventDefault();
    consentDetail.classList.toggle("open");
    consentLearnMore.textContent = consentDetail.classList.contains("open")
        ? "Show less ↑" : "Learn more ↗";
});

// ACCEPT → store consent, run geo, close banner
consentAccept.addEventListener("click", () => {
    localStorage.setItem(CONSENT_KEY, "accepted");
    hideConsent();
    agentSay("✅ Thanks! Detecting your region…");
    detectAndRecommend();
});

// DECLINE → no geo fetch, use default AI recommendation
consentDeclineBtn.addEventListener("click", () => {
    localStorage.setItem(CONSENT_KEY, "declined");
    hideConsent();
    agentSay("🔒 No worries! Showing default recommendation.");
    populateModal("ai", "📍 Location not shared");
    locationLine.textContent = "📍 Location not shared";
});

// Check if user already gave consent previously
function initConsent() {
    const saved = localStorage.getItem(CONSENT_KEY);
    if (saved === "accepted") {
        // Already accepted before — skip banner, run geo silently
        detectAndRecommend();
    } else if (saved === "declined") {
        // Already declined — use default, no banner
        populateModal("ai", "📍 Location not shared");
        locationLine.textContent = "📍 Location not shared";
    } else {
        // First visit — show the banner, hold the modal in loading state
        showConsent();
    }
}

initConsent();

/* ══════════════════════════════════════════
   ROAMING AGENT — SOL
══════════════════════════════════════════ */
const agentLines = [
    "👋 Hey! I'm Sol, your AI guide!",
    "🤖 Not sure which bot to pick?",
    "📍 I detected your location!",       // overwritten after geo
    "🚀 Both bots are live & ready!",
    "✨ Tap a card to get started!",
    "📊 10M+ conversations handled!",
    "⚡ 99.9% uptime. Zero downtime.",
    "🌟 I'll help you choose the right one!",
    "💬 Click me if you need a hint!",
];

const agentBot = document.getElementById("agentBot");
const agentBubble = document.getElementById("agentBubble");

let lineIndex = 0;
let roamActive = false;
let botX = 36, botY = window.innerHeight - 140;
let targetX = botX, targetY = botY;

function cycleAgentMessage() {
    agentSay(agentLines[lineIndex % agentLines.length]);
    lineIndex++;
}

// Sol cycles through lines even during modal (visible on page behind)
setInterval(cycleAgentMessage, 4500);

function lerp(a, b, t) { return a + (b - a) * t; }

function newRoamTarget() {
    const m = 90;
    targetX = m + Math.random() * (window.innerWidth - m * 2 - 80);
    targetY = m + Math.random() * (window.innerHeight - m * 2 - 100);
}

function roamTick() {
    // Skip position update while user is dragging
    if (!roamActive || isDragging) { requestAnimationFrame(roamTick); return; }

    botX = lerp(botX, targetX, 0.013);
    botY = lerp(botY, targetY, 0.013);

    agentBot.style.left = botX + "px";
    agentBot.style.top = botY + "px";
    agentBot.style.bottom = "auto";

    updateBubbleSide();

    // When close to target, pick a new one after a pause
    if (Math.abs(targetX - botX) < 5 && Math.abs(targetY - botY) < 5) {
        newRoamTarget();
    }

    requestAnimationFrame(roamTick);
}

function updateBubbleSide() {
    const nearRight = botX > window.innerWidth - 270;
    agentBubble.style.left = nearRight ? "auto" : "0";
    agentBubble.style.right = nearRight ? "0" : "auto";
}

function startRoaming() {
    roamActive = true;
    newRoamTarget();
}

// Start animation loop immediately
roamTick();

async function openFAQDrawer() {
    const drawer = document.getElementById("faqDrawer");
    const list = document.getElementById("faqList");

    drawer.classList.add("open");

    list.innerHTML = "Loading...";

    const faqs = await fetchFAQs();

    list.innerHTML = "";

    faqs.forEach(faq => {
        const div = document.createElement("div");
        div.className = "faq-item";

        div.innerHTML = `
      <div class="faq-q">${faq.question}</div>
      <div class="faq-a">${faq.answer}</div>
    `;

        list.appendChild(div);
    });
}

function closeFAQ() {
    document.getElementById("faqDrawer").classList.remove("open");
}

/* ══════════════════════════════════════════
   DRAG — mouse + touch
══════════════════════════════════════════ */
let isDragging = false;
let dragOffsetX = 0;
let dragOffsetY = 0;
let hasMoved = false;   // distinguish drag vs click
let resumeTimer = null;

function getEventXY(e) {
    if (e.touches) return { x: e.touches[0].clientX, y: e.touches[0].clientY };
    return { x: e.clientX, y: e.clientY };
}

function onDragStart(e) {
    // Don't start drag on the CTA buttons inside Sol
    if (e.target.closest("a, button")) return;

    const { x, y } = getEventXY(e);
    isDragging = true;
    hasMoved = false;
    dragOffsetX = x - botX;
    dragOffsetY = y - botY;

    clearTimeout(resumeTimer);

    agentBot.style.cursor = "grabbing";
    agentBot.style.animation = "none";        // pause float bob while dragging
    agentBot.style.transition = "none";

    agentSay("✋ Dragging me around?");

    // Prevent text selection while dragging
    e.preventDefault();
}

function onDragMove(e) {
    if (!isDragging) return;
    const { x, y } = getEventXY(e);

    // Clamp within viewport with a margin
    const margin = 20;
    botX = Math.min(Math.max(x - dragOffsetX, margin), window.innerWidth - 90 - margin);
    botY = Math.min(Math.max(y - dragOffsetY, margin), window.innerHeight - 110 - margin);

    agentBot.style.left = botX + "px";
    agentBot.style.top = botY + "px";
    agentBot.style.bottom = "auto";

    updateBubbleSide();
    hasMoved = true;
    e.preventDefault();
}

function onDragEnd(e) {
    if (!isDragging) return;
    isDragging = false;

    agentBot.style.cursor = "grab";
    agentBot.style.animation = "";   // restore float bob

    if (hasMoved) {
        // Drop — Sol stays put for 2s, then resumes roaming from new spot
        agentSay("📌 Dropped! I'll roam from here.");
        targetX = botX;
        targetY = botY;

        resumeTimer = setTimeout(() => {
            agentSay("🚶 Back to roaming!");
            newRoamTarget();
        }, 2000);
    }
}

// Mouse events
agentBot.addEventListener("mousedown", onDragStart);
document.addEventListener("mousemove", onDragMove);
document.addEventListener("mouseup", onDragEnd);

// Touch events (mobile)
agentBot.addEventListener("touchstart", onDragStart, { passive: false });
document.addEventListener("touchmove", onDragMove, { passive: false });
document.addEventListener("touchend", onDragEnd);

// ── Click Sol for a line (only if not dragged) ──
const clickLines = [
    "😄 I'm Sol — pick a bot!",
    "📱 WhatsApp Bot = conversational!",
    "🧠 AI Bot = deep automation!",
    "🎯 Both bots have 24/7 support!",
    "🔥 Tap the card to explore!",
    "🖱️ You can drag me anywhere!",
];
let clickIdx = 0;
agentBot.addEventListener("click", () => {
    if (hasMoved) return;

    agentSay("📚 Opening FAQs...");
    openFAQDrawer();
});