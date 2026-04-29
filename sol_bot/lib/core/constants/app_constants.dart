// lib/core/constants/app_constants.dart

class AppConstants {
  // ── Groq API ────────────────────────────────────────────
  static const String groqApiKey = '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';
  static const String groqBaseUrl =
      'https://api.groq.com/openai/v1/chat/completions';
  static const String groqModel = 'llama-3.1-8b-instant';

  // ── Supabase ─────────────────────────────────────────────
  static const String supabaseUrl = 'YOUR_SUPABASE_URL_HERE';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY_HERE';

  // ── App Info ─────────────────────────────────────────────
  static const String appName = 'Sol AI';
  static const String appTagline = 'Your Health Assistant';
  static const String botName = 'Sol';
  static const String clinicName = 'Warrior Homoeopath';

  // ── System Prompt ────────────────────────────────────────
  static const String systemPrompt = '''
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
''';

  // ── Quick Actions ────────────────────────────────────────
  static const List<Map<String, String>> quickActions = [
    {'label': 'About us', 'question': 'What is Warrior Homoeopath?'},
    {'label': 'Consultation', 'question': 'How are consultations conducted?'},
    {'label': 'Conditions', 'question': 'What conditions do you treat?'},
    {'label': 'Safety', 'question': 'Is homoeopathy safe?'},
    {'label': 'Book consultation', 'question': 'How do I book a consultation?'},
  ];

  // ── Suggestion Cards ─────────────────────────────────────
  static const List<Map<String, String>> suggestionCards = [
    {
      'icon': 'doctor',
      'title': 'About us',
      'subtitle': 'Understand our approach',
      'question': 'What is Warrior Homoeopath?',
    },
    {
      'icon': 'video',
      'title': 'Consultation process',
      'subtitle': 'How online consultation works',
      'question': 'How are consultations conducted?',
    },
    {
      'icon': 'heart',
      'title': 'Conditions treated',
      'subtitle': 'Chronic & complex cases',
      'question': 'What conditions do you treat?',
    },
    {
      'icon': 'calendar',
      'title': 'Book consultation',
      'subtitle': 'Start your treatment journey',
      'question': 'How do I book a consultation?',
    },
  ];

  // ── Recommendations Map ──────────────────────────────────
  static const Map<String, List<String>> recoMap = {
    'consultation': [
      'How are consultations conducted?',
      'Is consultation private?',
      'How do I book a consultation?',
    ],
    'treatment': [
      'What conditions do you treat?',
      'How long does treatment take?',
      'Is treatment personalised?',
    ],
    'safety': [
      'Is homoeopathy safe?',
      'Can children take treatment?',
      'Any side effects?',
    ],
    'default': [
      'What is Warrior Homoeopath?',
      'How does it work?',
      'How do I get started?',
    ],
  };

  // ── Stats ────────────────────────────────────────────────
  static const List<Map<String, String>> stats = [
    {'value': '1:1', 'label': 'Personalised care'},
    {'value': '100%', 'label': 'Private consultations'},
    {'value': '24/7', 'label': 'Always available guidance'},
  ];

  // ── Initial bot greeting ─────────────────────────────────
  static const String initialGreeting =
      "Hello 👋 I'm Sol.\nHow can I help you with your health concerns or consultation?";

  // ── Max conversation history to send to API ──────────────
  static const int maxHistoryLength = 20;

  // ── Toast duration ───────────────────────────────────────
  static const int toastDurationMs = 2600;
}
