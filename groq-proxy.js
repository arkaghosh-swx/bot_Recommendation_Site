/* ─────────────────────────────────────────
   SOLWORXS · GROQ PROXY SERVER
   Keeps GROQ_API_KEY secret on the server.
   Browser calls /api/chat → this forwards
   to Groq and returns the response.
───────────────────────────────────────── */

const express = require("express");
const cors = require("cors");
require("dotenv").config();          // reads .env file

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

// ── Serve your frontend files statically ──
app.use(express.static("public"));   // put your HTML/CSS/JS in /public folder

// ── Proxy endpoint ─────────────────────────────────────────
app.post("/api/chat", async (req, res) => {

    const GROQ_API_KEY = process.env.GROQ_API_KEY;

    if (!GROQ_API_KEY) {
        return res.status(500).json({ error: "GROQ_API_KEY not set on server." });
    }

    try {
        const response = await fetch("https://api.groq.com/openai/v1/chat/completions", {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
                "Authorization": `Bearer ${GROQ_API_KEY}`,   // key stays on server ✅
            },
            body: JSON.stringify(req.body),   // forward exactly what browser sent
        });

        const data = await response.json();
        res.json(data);

    } catch (err) {
        console.error("Groq proxy error:", err);
        res.status(500).json({ error: "Proxy request failed." });
    }

});

app.listen(PORT, () => {
    console.log(`✅ Solworxs proxy running on http://localhost:${PORT}`);
});