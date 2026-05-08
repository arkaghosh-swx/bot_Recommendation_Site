require("dotenv").config();
const express = require("express");
const cors = require("cors");

const app = express();
app.use(express.json());
app.use(cors());

const PORT = process.env.PORT || 3000;
const GROQ_API_KEY = process.env.GROQ_API_KEY;

const SYSTEM_PROMPT = `
You are Swx Bot — an intelligent support assistant.
Your role:
- Help users understand services, consultations, and treatments
- Answer FAQs clearly and concisely
- Guide users to book a consultation
- Build trust (medical, calm, professional tone)
Rules:
- Do NOT give medical diagnosis
- Keep answers short, clear, and reassuring
- If unsure → guide user to consultation
Tone: Calm, professional, human-like.
`;

// ── Chat proxy (hides Groq key from browser)
app.post("/api/chat", async (req, res) => {
    try {
        const { messages } = req.body;
        const response = await fetch("https://api.groq.com/openai/v1/chat/completions", {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
                "Authorization": "Bearer " + GROQ_API_KEY,
            },
            body: JSON.stringify({
                model: "llama-3.1-8b-instant",
                messages,
                temperature: 0.7,
                max_tokens: 1024,
            }),
        });
        const data = await response.json();
        const reply = data.choices?.[0]?.message?.content || "No response received.";
        res.json({ reply });
    } catch (err) {
        console.error("Chat error:", err.message);
        res.status(500).json({ reply: "⚠️ Something went wrong. Please try again." });
    }
});

// ── Health check
app.get("/", (req, res) => res.send("Swx Web Bot is running ✅"));

app.listen(PORT, () => console.log(`Server running on port ${PORT}`));