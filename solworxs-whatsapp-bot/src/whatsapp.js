const https = require("https");

const PHONE_NUMBER_ID = process.env.WHATSAPP_PHONE_NUMBER_ID;
const ACCESS_TOKEN = process.env.WHATSAPP_ACCESS_TOKEN;

// ── Core sender ──────────────────────────────────────────────
function sendRequest(payload) {
  return new Promise((resolve, reject) => {
    const body = JSON.stringify(payload);
    const options = {
      hostname: "graph.facebook.com",
      path: `/v19.0/${PHONE_NUMBER_ID}/messages`,
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${ACCESS_TOKEN}`,
        "Content-Length": Buffer.byteLength(body),
      },
    };

    const req = https.request(options, (res) => {
      let data = "";
      res.on("data", (chunk) => (data += chunk));
      res.on("end", () => {
        if (res.statusCode === 200 || res.statusCode === 201) {
          resolve(JSON.parse(data));
        } else {
          console.error("WhatsApp API error:", data);
          reject(new Error(`WhatsApp API responded with ${res.statusCode}`));
        }
      });
    });

    req.on("error", reject);
    req.write(body);
    req.end();
  });
}

// ── 1. Plain text message ─────────────────────────────────────
function sendTextMessage(to, text) {
  return sendRequest({
    messaging_product: "whatsapp",
    to,
    type: "text",
    text: { body: text },
  });
}

// ── 2. List Menu (up to 10 items) ────────────────────────────
function sendListMenu(to) {
  return sendRequest({
    messaging_product: "whatsapp",
    to,
    type: "interactive",
    interactive: {
      type: "list",
      header: {
        type: "text",
        text: "👋 Welcome to Solworxs AI",
      },
      body: {
        text: "We build enterprise-grade AI bots that automate workflows and elevate customer experiences.\n\nHow can I help you today?",
      },
      footer: {
        text: "Solworxs • solworxs.com",
      },
      action: {
        button: "📋 View Options",
        sections: [
          {
            title: "Our Services",
            rows: [
              { id: "menu_products", title: "🤖 Our AI Bots", description: "Support Bot, AI Assistant, WhatsApp Bot" },
              { id: "menu_pricing", title: "💰 Pricing", description: "Plans and packages" },
              { id: "menu_demo", title: "📅 Book a Demo", description: "Schedule a free demo session" },
            ],
          },
          {
            title: "Support",
            rows: [
              { id: "menu_support", title: "🙋 Talk to Our Team", description: "Get in touch with a human" },
              { id: "menu_faq", title: "❓ FAQs", description: "Common questions answered" },
              { id: "menu_about", title: "🏢 About Solworxs", description: "Who we are and what we do" },
            ],
          },
        ],
      },
    },
  });
}

// ── 3. Button Message (up to 3 buttons) ──────────────────────
function sendButtonMessage(to, bodyText, buttons) {
  return sendRequest({
    messaging_product: "whatsapp",
    to,
    type: "interactive",
    interactive: {
      type: "button",
      body: { text: bodyText },
      action: {
        buttons: buttons.map((b) => ({
          type: "reply",
          reply: { id: b.id, title: b.title },
        })),
      },
    },
  });
}

module.exports = {
  sendTextMessage,
  sendListMenu,
  sendButtonMessage,
};
