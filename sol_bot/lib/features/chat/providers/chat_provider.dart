// lib/features/chat/providers/chat_provider.dart

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/chat_message.dart';
import '../models/chat_session.dart';
import '../models/faq_model.dart';
import '../services/groq_service.dart';
import '../services/faq_service.dart';
import '../../../core/constants/app_constants.dart';

/// Mirrors all state + logic from assistant.js
class ChatProvider extends ChangeNotifier {
  final _uuid = const Uuid();

  // ── Sessions ──────────────────────────────────────────────
  final List<ChatSession> sessions = [];
  ChatSession? activeSession;

  // ── FAQs (cached once like the JS version) ────────────────
  List<FaqItem> _faqs = [];
  bool _faqsLoaded = false;

  // ── UI state ──────────────────────────────────────────────
  bool isTyping = false;
  bool drawerExpanded = false;
  bool sidebarOpen = false;
  bool searchBarOpen = false;
  String searchQuery = '';

  // ── Reco chips (mirrors JS recoBar) ──────────────────────
  List<String> recoChips = [];
  bool showRecoBar = false;

  // ── Messages shortcut ─────────────────────────────────────
  List<ChatMessage> get messages => activeSession?.messages ?? [];

  // ── Init ──────────────────────────────────────────────────
  Future<void> init() async {
    _faqs = await FaqService.fetchFaqs();
    _faqsLoaded = true;
    startNewChat(isInit: true);
  }

  // ── Start new chat ────────────────────────────────────────
  void startNewChat({bool isInit = false}) {
    final session = ChatSession(id: _uuid.v4(), label: 'New conversation');
    sessions.insert(0, session);
    activeSession = session;
    drawerExpanded = false;
    recoChips = [];
    showRecoBar = false;
    sidebarOpen = false;

    // Initial greeting (bot message)
    _addBotMessage(AppConstants.initialGreeting, animate: false);
    notifyListeners();
  }

  // ── Load session ──────────────────────────────────────────
  void loadSession(ChatSession session) {
    activeSession = session;
    drawerExpanded = false;
    recoChips = [];
    showRecoBar = false;
    sidebarOpen = false;
    notifyListeners();
  }

  // ── Delete session ────────────────────────────────────────
  void deleteSession(ChatSession session) {
    sessions.remove(session);
    if (activeSession?.id == session.id) {
      if (sessions.isNotEmpty) {
        activeSession = sessions.first;
      } else {
        startNewChat();
        return;
      }
    }
    notifyListeners();
  }

  // ── Rename session ────────────────────────────────────────
  void renameSession(ChatSession session, String newLabel) {
    session.label = newLabel;
    notifyListeners();
  }

  // ── Send message ──────────────────────────────────────────
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    _addUserMessage(text.trim());
    drawerExpanded = true;
    isTyping = true;
    showRecoBar = false;
    recoChips = [];
    notifyListeners();

    // Ensure FAQs loaded
    if (!_faqsLoaded) {
      _faqs = await FaqService.fetchFaqs();
      _faqsLoaded = true;
    }

    final faqContext = FaqService.buildContext(_faqs);
    final matched = FaqService.findDirectMatch(text, _faqs);

    String reply;
    if (matched != null) {
      // Instant FAQ answer — no API call (mirrors JS checkFAQFirst)
      reply = matched.answer;
    } else {
      reply = await GroqService.chat(
        userMessage: text.trim(),
        history: activeSession?.trimmedApiHistory ?? [],
        faqContext: faqContext,
      );
    }

    activeSession?.addToApiHistory('assistant', reply);

    isTyping = false;
    _addBotMessage(reply);

    // Show reco chips
    recoChips = _getRecos(text);
    showRecoBar = recoChips.isNotEmpty;

    notifyListeners();
  }

  // ── Drawer control ────────────────────────────────────────
  void expandDrawer() {
    drawerExpanded = true;
    notifyListeners();
  }

  void collapseDrawer() {
    drawerExpanded = false;
    notifyListeners();
  }

  void toggleDrawer() {
    drawerExpanded = !drawerExpanded;
    notifyListeners();
  }

  // ── Sidebar ───────────────────────────────────────────────
  void toggleSidebar() {
    sidebarOpen = !sidebarOpen;
    notifyListeners();
  }

  void closeSidebar() {
    sidebarOpen = false;
    notifyListeners();
  }

  // ── Search bar ────────────────────────────────────────────
  void toggleSearchBar() {
    searchBarOpen = !searchBarOpen;
    if (!searchBarOpen) searchQuery = '';
    notifyListeners();
  }

  void updateSearch(String q) {
    searchQuery = q;
    notifyListeners();
  }

  // ── Export chat ───────────────────────────────────────────
  String exportChatText() {
    if (activeSession == null || activeSession!.messages.isEmpty) return '';
    final lines = [
      'Sol — Warrior Homoeopath Assistant',
      '=' * 50,
      'Date: ${DateTime.now()}',
      '',
    ];
    for (final m in activeSession!.messages) {
      lines.add(
        '[${m.formattedTime}] ${m.role == MessageRole.user ? "You" : "Sol AI"}:',
      );
      lines.add(m.text);
      lines.add('');
    }
    return lines.join('\n');
  }

  // ── Private helpers ───────────────────────────────────────
  void _addUserMessage(String text) {
    final msg = ChatMessage(
      id: _uuid.v4(),
      role: MessageRole.user,
      text: text,
      time: DateTime.now(),
    );
    activeSession?.addMessage(msg);
    activeSession?.addToApiHistory('user', text);
    notifyListeners();
  }

  void _addBotMessage(String text, {bool animate = true}) {
    final msg = ChatMessage(
      id: _uuid.v4(),
      role: MessageRole.bot,
      text: text,
      time: DateTime.now(),
    );
    activeSession?.messages.add(msg);
    notifyListeners();
  }

  // ── Reco map (mirrors JS RECO_MAP) ────────────────────────
  List<String> _getRecos(String text) {
    final t = text.toLowerCase();
    if (t.contains('consult')) {
      return AppConstants.recoMap['consultation'] ?? [];
    }
    if (t.contains('treat') || t.contains('condition')) {
      return AppConstants.recoMap['treatment'] ?? [];
    }
    if (t.contains('safe') || t.contains('side')) {
      return AppConstants.recoMap['safety'] ?? [];
    }
    return AppConstants.recoMap['default'] ?? [];
  }
}
