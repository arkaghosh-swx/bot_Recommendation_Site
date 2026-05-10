// /home/solworxs11/Public/botRecommendationSite/solworxs-whatsapp-bot/src/whatsapp.js
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
      header: { type: "text", text: "👋 Welcome to Warrior Homoeopath" },
      body: {
        text: "Precision Homoeopathic care for chronic and complex conditions — worldwide. 🌿\n\nHow can I help you today?",
      },
      footer: { text: "Aude sapere. Dare to heal." },
      action: {
        button: "📋 View Options",
        sections: [
          {
            title: "About & Conditions",
            rows: [
              { id: "menu_about", title: "🏥 About Us", description: "Who we are and our approach" },
              { id: "menu_conditions", title: "🩺 Conditions Treated", description: "What we can help with" },
            ],
          },
          {
            title: "Consultations",
            rows: [
              { id: "menu_consult", title: "💬 How It Works", description: "Online consultation details" },
              { id: "menu_pricing", title: "💰 Pricing", description: "Consultation fees in GBP & INR" },
              { id: "menu_book", title: "📅 Book Now", description: "Schedule your consultation" },
            ],
          },
          {
            title: "Support",
            rows: [
              { id: "menu_contact", title: "📞 Contact Us", description: "Email, phone & WhatsApp" },
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
