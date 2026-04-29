/* ─────────────────────────────────────────
   SOLWORXS · FAQ DRAWER · FAQ.JS
   Supabase → fetch FAQs → Sol introduces
   them after the consent + modal flow
───────────────────────────────────────── */

/* ══════════════════════════════════════════
   SUPABASE CONFIG
   Replace with your actual project values
══════════════════════════════════════════ */
const SUPABASE_URL = "https://sbzoxwvuoidtywvkabmz.supabase.co";
const SUPABASE_ANON = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNiem94d3Z1b2lkdHl3dmthYm16Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzYxNDYzNTAsImV4cCI6MjA5MTcyMjM1MH0.IrfSKiuShXz0RA26fn5NFUS-VLk3mQAwJoSu28prju4";

/* ── Supabase client (using CDN — add to index.html head if not already there)
   <script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>
──────────────────────────────────────────────────────────────────────────────── */
/* ── Supabase client (using CDN — add to index.html head if not already there)
   <script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>
──────────────────────────────────────────────────────────────────────────────── */
const { createClient } = supabase;
const db = createClient(SUPABASE_URL, SUPABASE_ANON);

/* ══════════════════════════════════════════
   STATE
══════════════════════════════════════════ */
let allFaqs = [];      // raw data from Supabase
let activeCategory = "all";  // current filter
let faqLoaded = false;   // prevent duplicate fetches
let hintTimer = null;

/* ══════════════════════════════════════════
   DOM REFS
══════════════════════════════════════════ */
const faqDrawer = document.getElementById("faqDrawer");
const faqOverlay = document.getElementById("faqOverlay");
const faqLoading = document.getElementById("faqLoading");
const faqError = document.getElementById("faqError");
const faqContent = document.getElementById("faqContent");
const faqEmpty = document.getElementById("faqEmpty");
const faqEmptyQuery = document.getElementById("faqEmptyQuery");
const faqCategoryTabs = document.getElementById("faqCategoryTabs");
const faqSearchInput = document.getElementById("faqSearchInput");
const faqSearchClear = document.getElementById("faqSearchClear");
const solFaqHint = document.getElementById("solFaqHint");
const agentBotEl = document.getElementById("agentBot");

/* ══════════════════════════════════════════
   SUPABASE — FETCH FAQS
   Expected table: faqs
   Columns: id, question, answer, category, sort_order
   RLS: enable read for anon
══════════════════════════════════════════ */
async function loadFaqs() {
    showState("loading");

    try {
        const { data, error } = await db
            .from("faqs")
            .select("id, question, answer, category, sort_order")
            .order("sort_order", { ascending: true });

        if (error) throw error;

        allFaqs = data || [];
        faqLoaded = true;

        buildCategoryTabs();
        renderFaqs("all", "");
        showState("content");

    } catch (err) {
        console.error("FAQ fetch error:", err);
        showState("error");
    }
}

/* ══════════════════════════════════════════
   BUILD CATEGORY TABS
══════════════════════════════════════════ */
function buildCategoryTabs() {
    // Extract unique categories preserving order of first appearance
    const seen = new Set();
    const categories = [];
    allFaqs.forEach(faq => {
        if (!seen.has(faq.category)) {
            seen.add(faq.category);
            categories.push(faq.category);
        }
    });

    faqCategoryTabs.innerHTML = "";

    // "All" tab
    const allBtn = document.createElement("button");
    allBtn.className = "faq-cat-btn active";
    allBtn.textContent = `All (${allFaqs.length})`;
    allBtn.dataset.cat = "all";
    allBtn.onclick = () => switchCategory("all", allBtn);
    faqCategoryTabs.appendChild(allBtn);

    // Category tabs
    categories.forEach(cat => {
        const count = allFaqs.filter(f => f.category === cat).length;
        const btn = document.createElement("button");
        btn.className = "faq-cat-btn";
        btn.textContent = `${cat} (${count})`;
        btn.dataset.cat = cat;
        btn.onclick = () => switchCategory(cat, btn);
        faqCategoryTabs.appendChild(btn);
    });
}

/* ══════════════════════════════════════════
   SWITCH CATEGORY
══════════════════════════════════════════ */
function switchCategory(cat, btn) {
    activeCategory = cat;

    // Update tab styles
    document.querySelectorAll(".faq-cat-btn").forEach(b => b.classList.remove("active"));
    btn.classList.add("active");

    // Re-render with current search
    const query = faqSearchInput ? faqSearchInput.value.trim() : "";
    renderFaqs(cat, query);
}

/* ══════════════════════════════════════════
   RENDER FAQS
══════════════════════════════════════════ */
function renderFaqs(category, searchQuery) {
    // Filter by category
    let filtered = category === "all"
        ? [...allFaqs]
        : allFaqs.filter(f => f.category === category);

    // Filter by search
    const q = searchQuery.toLowerCase().trim();
    if (q) {
        filtered = filtered.filter(f =>
            f.question.toLowerCase().includes(q) ||
            f.answer.toLowerCase().includes(q)
        );
    }

    // Empty state
    if (filtered.length === 0) {
        if (q) {
            faqEmptyQuery.textContent = searchQuery;
            showState("empty");
        } else {
            showState("content");
            faqContent.innerHTML = `<p style="color:#64748b;font-size:13px;text-align:center;padding:40px 0">No questions in this category yet.</p>`;
        }
        return;
    }

    showState("content");

    // Group by category for display
    const groups = {};
    filtered.forEach(faq => {
        const cat = faq.category;
        if (!groups[cat]) groups[cat] = [];
        groups[cat].push(faq);
    });

    faqContent.innerHTML = "";

    // If single category or all under one group, skip group label
    const groupKeys = Object.keys(groups);
    const showLabels = groupKeys.length > 1;

    groupKeys.forEach(cat => {
        const group = document.createElement("div");
        group.className = "faq-group";

        if (showLabels) {
            const label = document.createElement("div");
            label.className = "faq-group-label";
            label.innerHTML = `<i class="fa-solid fa-folder-open"></i> ${cat}`;
            group.appendChild(label);
        }

        groups[cat].forEach((faq, idx) => {
            const item = buildFaqItem(faq, q);
            group.appendChild(item);
        });

        faqContent.appendChild(group);
    });
}

/* ══════════════════════════════════════════
   BUILD SINGLE FAQ ITEM
══════════════════════════════════════════ */
function buildFaqItem(faq, highlight) {
    const item = document.createElement("div");
    item.className = "faq-item";
    item.dataset.id = faq.id;

    const qText = highlight ? highlightText(faq.question, highlight) : faq.question;
    const aText = highlight ? highlightText(faq.answer, highlight) : faq.answer;

    item.innerHTML = `
    <button class="faq-question" onclick="toggleFaqItem(this)">
      <span class="faq-question-text">${qText}</span>
      <span class="faq-chevron"><i class="fa-solid fa-chevron-down"></i></span>
    </button>
    <div class="faq-answer">
      <div class="faq-answer-inner">
        <p>${aText}</p>
      </div>
    </div>
  `;

    return item;
}

/* ══════════════════════════════════════════
   TOGGLE FAQ ITEM
══════════════════════════════════════════ */
function toggleFaqItem(btn) {
    const item = btn.closest(".faq-item");
    const isOpen = item.classList.contains("open");

    // Close all others in the same group
    const siblings = item.closest(".faq-group, .faq-content").querySelectorAll(".faq-item");
    siblings.forEach(s => s.classList.remove("open"));

    if (!isOpen) item.classList.add("open");
}

/* ══════════════════════════════════════════
   SEARCH
══════════════════════════════════════════ */
function searchFaqs(query) {
    // Show/hide clear button
    if (faqSearchClear) {
        faqSearchClear.style.display = query.length > 0 ? "block" : "none";
    }

    // Reset to "all" category when searching
    if (query.length > 0 && activeCategory !== "all") {
        activeCategory = "all";
        document.querySelectorAll(".faq-cat-btn").forEach(b => {
            b.classList.toggle("active", b.dataset.cat === "all");
        });
    }

    renderFaqs(activeCategory, query);
}

function clearFaqSearch() {
    if (faqSearchInput) faqSearchInput.value = "";
    if (faqSearchClear) faqSearchClear.style.display = "none";
    renderFaqs(activeCategory, "");
    faqSearchInput?.focus();
}

/* ══════════════════════════════════════════
   HIGHLIGHT SEARCH MATCH
══════════════════════════════════════════ */
function highlightText(text, query) {
    if (!query) return text;
    const safe = query.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
    return text.replace(
        new RegExp(`(${safe})`, "gi"),
        '<span class="faq-highlight">$1</span>'
    );
}

/* ══════════════════════════════════════════
   SHOW / HIDE STATES
══════════════════════════════════════════ */
function showState(state) {
    faqLoading.style.display = state === "loading" ? "flex" : "none";
    faqError.style.display = state === "error" ? "flex" : "none";
    faqContent.style.display = state === "content" ? "flex" : "none";
    faqEmpty.style.display = state === "empty" ? "flex" : "none";
}

/* ══════════════════════════════════════════
   OPEN / CLOSE DRAWER
══════════════════════════════════════════ */
function openFaqDrawer() {
    faqDrawer.classList.add("open");
    faqOverlay.classList.add("active");
    document.body.style.overflow = "hidden";

    // Hide hint bubble
    hideSolHint();

    // Load FAQs on first open
    if (!faqLoaded) loadFaqs();

    // Tell Sol
    if (typeof agentSay === "function") agentSay("📖 Here are our FAQs!");
}

function closeFaqDrawer() {
    faqDrawer.classList.remove("open");
    faqOverlay.classList.remove("active");
    document.body.style.overflow = "";

    // Clear search
    if (faqSearchInput) faqSearchInput.value = "";
    if (faqSearchClear) faqSearchClear.style.display = "none";

    // ── After closing FAQ for the first time, reveal the recommendation modal ──
    const justOnboarded = sessionStorage.getItem("solworxs_show_modal_after_faq");
    if (justOnboarded) {
        sessionStorage.removeItem("solworxs_show_modal_after_faq");
        // Modal is already populated (geo ran in background), just make it visible
        if (typeof agentSay === "function") agentSay("🤖 Now pick your bot!");
        // Modal is already showing — nothing to do, it was never hidden
    }
}

/* keyboard close */
document.addEventListener("keydown", e => {
    if (e.key === "Escape" && faqDrawer.classList.contains("open")) {
        closeFaqDrawer();
    }
});

/* ══════════════════════════════════════════
   SOL HINT BUBBLE
   Appears near Sol after modal closes,
   prompting user to click Sol for FAQs
══════════════════════════════════════════ */
function showSolHint() {
    if (!solFaqHint || !agentBotEl) return;

    positionSolHint();
    solFaqHint.classList.add("visible");

    // Auto-hide after 5s
    hintTimer = setTimeout(() => {
        hideSolHint();
    }, 5000);
}

function hideSolHint() {
    clearTimeout(hintTimer);
    if (solFaqHint) solFaqHint.classList.remove("visible");
}

function positionSolHint() {
    // Position hint above Sol's current position
    const rect = agentBotEl.getBoundingClientRect();
    solFaqHint.style.left = rect.left + "px";
    solFaqHint.style.top = (rect.top - 52) + "px";
}

/* Reposition hint if Sol moves */
const _origRoamTick = window.roamTick;

/* ══════════════════════════════════════════
   WIRE UP SOL CLICK → OPEN FAQ DRAWER
   This overrides the click handler set
   in script.js AFTER modal closes
══════════════════════════════════════════ */
function initFaqSolIntegration() {
    if (!agentBotEl) return;

    // Listen for Sol clicks and open FAQ drawer
    agentBotEl.addEventListener("click", () => {
        // Only open if not dragging (hasMoved is set in script.js)
        if (typeof hasMoved !== "undefined" && hasMoved) return;
        openFaqDrawer();
    });
}

/* ══════════════════════════════════════════
   HOOK INTO MODAL CLOSE EVENT
   - First visit  → auto-open FAQ drawer
   - Return visit → show Sol hint bubble
══════════════════════════════════════════ */
const FAQ_SEEN_KEY = "solworxs_faq_seen";

(function watchForModalClose() {
    const pageWrap = document.getElementById("pageWrap");
    if (!pageWrap) return;

    function handlePageVisible() {
        // Return visits only — show Sol hint bubble
        setTimeout(() => {
            showSolHint();
            if (typeof agentSay === "function") agentSay("👆 Click me for FAQs!");
        }, 2500);
    }

    if (pageWrap.classList.contains("visible")) {
        handlePageVisible();
        return;
    }

    const observer = new MutationObserver((mutations) => {
        mutations.forEach(m => {
            if (
                m.type === "attributes" &&
                m.attributeName === "class" &&
                pageWrap.classList.contains("visible")
            ) {
                observer.disconnect();
                handlePageVisible();
            }
        });
    });

    observer.observe(pageWrap, { attributes: true });
})();

/* ══════════════════════════════════════════
   INIT
══════════════════════════════════════════ */
(function initFaq() {
    initFaqSolIntegration();
})();