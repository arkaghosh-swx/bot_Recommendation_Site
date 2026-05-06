// lib/features/chat/screens/assistant_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:sol_bot/features/settings/providers/settings_provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../providers/chat_provider.dart';
import '../widgets/message_bubble.dart';
import '../widgets/typing_indicator.dart';
import '../widgets/chat_composer.dart';
import '../widgets/reco_bar.dart';
import '../widgets/chat_devider.dart';
import '../../home/widgets/hero_section.dart';
import '../../home/widgets/suggestion_cards.dart';
import '../../sidebar/widgets/app_sidebar.dart';
import '../../../shared/widgets/app_background.dart';

class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key});

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen>
    with TickerProviderStateMixin {
  final TextEditingController _inputCtrl = TextEditingController();
  final ScrollController _msgScroll = ScrollController();
  final ScrollController _mainScroll = ScrollController();
  final FocusNode _inputFocus = FocusNode();
  final TextEditingController _searchCtrl = TextEditingController();

  // Peek height: handle pill (3px) + "CHAT WITH SWX AI" label + padding
  static const double _peekHeight = 80.0;

  // Single bool drives open/closed — TweenAnimationBuilder handles the pixel
  // height so there is never a mismatch between constraint and content.
  bool _drawerOpen = false;

  double _dragStartY = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().init();
    });
    _inputFocus.addListener(() {
      if (_inputFocus.hasFocus) _open();
    });
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _msgScroll.dispose();
    _mainScroll.dispose();
    _inputFocus.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _open() {
    setState(() => _drawerOpen = true);
    context.read<ChatProvider>().expandDrawer();
  }

  void _close() {
    setState(() => _drawerOpen = false);
    context.read<ChatProvider>().collapseDrawer();
  }

  void _toggle() => _drawerOpen ? _close() : _open();

  void _onDragStart(DragStartDetails d) => _dragStartY = d.globalPosition.dy;

  void _onDragEnd(DragEndDetails d) {
    final dy = _dragStartY - d.globalPosition.dy;
    if (dy > 40) _open();
    if (dy < -40) _close();
  }

  void _sendMessage() {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) return;
    _inputCtrl.clear();
    final settings = context.read<SettingsProvider>();

    context
        .read<ChatProvider>()
        .sendMessage(text, settings: settings) // ← pass settings
        .then((_) => _scrollToBottom());
    _open();
    _scrollToBottom();
  }

  void _quickAsk(String q) {
    _inputCtrl.text = q;
    _sendMessage();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_msgScroll.hasClients) {
        _msgScroll.animateTo(
          _msgScroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _exportChat() async {
    final chat = context.read<ChatProvider>();
    final text = chat.exportChatText();
    if (text.isEmpty) {
      _showToast('Nothing to export yet.');
      return;
    }
    await Share.share(text, subject: 'Swx — Chat Export');
    _showToast('Chat exported 📄');
  }

  void _showToast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: Duration(milliseconds: AppConstants.toastDurationMs),
        backgroundColor: AppColors.surface3,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
          side: const BorderSide(color: Color(0x4D3B82F6)),
        ),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Consumer<ChatProvider>(
      builder: (context, chat, _) {
        if (chat.drawerExpanded && !_drawerOpen) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && chat.drawerExpanded && !_drawerOpen) {
              setState(() => _drawerOpen = true);
            }
          });
        }
        if (chat.messages.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => _scrollToBottom(),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.bg,
          body: AppBackground(
            child: isMobile
                ? _buildMobileLayout(context, chat)
                : _buildDesktopLayout(context, chat),
          ),
        );
      },
    );
  }

  // ── Desktop: sidebar + main area side by side ──────────────
  Widget _buildDesktopLayout(BuildContext ctx, ChatProvider chat) {
    return Row(
      children: [
        const AppSidebar(),
        // Subtle vertical divider glow
        Container(
          width: 1,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Color(0x4D3B82F6),
                Color(0x4D3B82F6),
                Colors.transparent,
              ],
              stops: [0, 0.3, 0.7, 1],
            ),
          ),
        ),
        // LayoutBuilder gives the true pixel height of this column,
        // avoiding the MediaQuery-vs-actual-space mismatch on Linux.
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) => _buildMainArea(
              ctx,
              chat,
              availableHeight: constraints.maxHeight,
            ),
          ),
        ),
      ],
    );
  }

  // ── Mobile: topbar + main area stacked ────────────────────
  Widget _buildMobileLayout(BuildContext ctx, ChatProvider chat) {
    return Column(
      children: [
        // Fixed topbar
        _buildTopbar(chat),
        // Main area fills the rest — LayoutBuilder measures only this portion,
        // so the drawer never tries to be taller than the space below the topbar.
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) => Stack(
              children: [
                // Hero + suggestion cards (hidden when chat is open)
                _buildScrollableHome(chat),
                // Chat shell anchored to bottom of THIS stack
                _buildChatShell(
                  chat,
                  constraints.maxHeight,
                  context.read<SettingsProvider>().isLight,
                ),
                // Sidebar overlay (mobile only)
                if (chat.sidebarOpen) ...[
                  GestureDetector(
                    onTap: chat.closeSidebar,
                    child: Container(color: Colors.black54),
                  ),
                  const Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: AppSidebar(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Shared main area (desktop uses this directly) ──────────
  Widget _buildMainArea(
    BuildContext ctx,
    ChatProvider chat, {
    required double availableHeight,
  }) {
    final isLight = ctx.read<SettingsProvider>().isLight;
    return Stack(
      children: [
        _buildScrollableHome(chat),
        _buildChatShell(chat, availableHeight, isLight),
      ],
    );
  }

  // ── Scrollable hero + suggestion cards ────────────────────
  Widget _buildScrollableHome(ChatProvider chat) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: _drawerOpen ? 0 : 1,
      child: IgnorePointer(
        ignoring: _drawerOpen,
        child: SingleChildScrollView(
          controller: _mainScroll,
          child: Column(
            children: [
              const HeroSection(),
              SuggestionCards(onCardTap: _quickAsk),
              // Space so content isn't hidden under collapsed shell
              const SizedBox(height: _peekHeight + 40),
            ],
          ),
        ),
      ),
    );
  }

  // ── Mobile topbar ──────────────────────────────────────────
  Widget _buildTopbar(ChatProvider chat) {
    return Container(
      height: 58 + MediaQuery.of(context).padding.top,
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: MediaQuery.of(context).padding.top,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          _TopbarBtn(icon: Icons.menu, onTap: chat.toggleSidebar),
          const SizedBox(width: 12),
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Center(
              child: Text(
                'S',
                style: TextStyle(
                  fontFamily: 'Syne',
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: AppColors.bg,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'Swx AI',
            style: TextStyle(
              fontFamily: 'Syne',
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: AppColors.text,
            ),
          ),
          const Spacer(),
          _TopbarBtn(icon: Icons.add, onTap: chat.startNewChat),
        ],
      ),
    );
  }

  // ── Chat Shell ─────────────────────────────────────────────
  // availableHeight comes from LayoutBuilder — it is the true pixel height
  // of the Stack this shell lives in, on every platform including Linux desktop.
  Widget _buildChatShell(
    ChatProvider chat,
    double availableHeight,
    bool isLight,
  ) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: GestureDetector(
        onVerticalDragStart: _onDragStart,
        onVerticalDragEnd: _onDragEnd,
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(
            begin: _drawerOpen ? availableHeight : _peekHeight,
            end: _drawerOpen ? availableHeight : _peekHeight,
          ),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          builder: (context, height, _) {
            // Every branch decision is derived from the same `height` double
            // that is also the layout constraint. No boolean can disagree.
            final bool showFull = height > 180;
            final bool showTopbar = height > 160;
            final bool showSearch = chat.searchBarOpen && height > 280;
            final bool showReco = chat.showRecoBar && height > 300;
            final bool showComposer = height > 200;
            final isLight = context.read<SettingsProvider>().isLight;
            return SizedBox(
              height: height,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: isLight ? AppColors.lightSurface : AppColors.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 48,
                      offset: const Offset(0, -8),
                    ),
                    const BoxShadow(
                      color: Color(0x1F3B82F6),
                      blurRadius: 0,
                      spreadRadius: -1,
                      offset: Offset(0, -1),
                    ),
                  ],
                ),
                child: ClipRect(
                  child: showFull
                      ? _buildExpandedShell(
                          chat: chat,
                          showTopbar: showTopbar,
                          showSearch: showSearch,
                          showReco: showReco,
                          showComposer: showComposer,
                        )
                      : _buildPeekShell(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ── Collapsed shell — handle pill + label only ─────────────
  Widget _buildPeekShell() {
    return SizedBox(
      height: _peekHeight,
      width: double.infinity,
      child: _DrawerHandle(isExpanded: false, onTap: _toggle),
    );
  }

  // ── Expanded shell — full chat UI ─────────────────────────
  Widget _buildExpandedShell({
    required ChatProvider chat,
    required bool showTopbar,
    required bool showSearch,
    required bool showReco,
    required bool showComposer,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        _DrawerHandle(isExpanded: true, onTap: _toggle),

        if (showTopbar)
          _ChatTopbar(
            onSearch: () {
              chat.toggleSearchBar();
              if (chat.searchBarOpen) {
                Future.delayed(
                  const Duration(milliseconds: 50),
                  _searchCtrl.clear,
                );
              }
            },
            onExport: _exportChat,
          ),

        if (showSearch)
          _ChatSearchBar(
            controller: _searchCtrl,
            onChanged: chat.updateSearch,
            onClose: () {
              chat.toggleSearchBar();
              _searchCtrl.clear();
            },
          ),

        Expanded(
          child: _MessagesList(
            messages: _filteredMessages(chat),
            isTyping: chat.isTyping && context.read<SettingsProvider>().typing,
            scrollController: _msgScroll,
            searchQuery: chat.searchQuery,
          ),
        ),

        if (showReco && context.read<SettingsProvider>().chips)
          RecoBar(chips: chat.recoChips, onChipTap: _quickAsk),

        if (showComposer)
          ChatComposer(
            controller: _inputCtrl,
            onSend: _sendMessage,
            disabled: chat.isTyping,
            focusNode: _inputFocus,
          ),
      ],
    );
  }

  List _filteredMessages(ChatProvider chat) {
    if (chat.searchQuery.isEmpty) return chat.messages;
    final q = chat.searchQuery.toLowerCase();
    return chat.messages
        .where((m) => m.text.toLowerCase().contains(q))
        .toList();
  }
}

// ── Drawer handle ──────────────────────────────────────────
class _DrawerHandle extends StatefulWidget {
  final bool isExpanded;
  final VoidCallback onTap;
  const _DrawerHandle({required this.isExpanded, required this.onTap});

  @override
  State<_DrawerHandle> createState() => _DrawerHandleState();
}

class _DrawerHandleState extends State<_DrawerHandle> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: SizedBox(
          height: widget.isExpanded ? 36 : 52,
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: _hovered ? 50 : 38,
                height: 3,
                decoration: BoxDecoration(
                  color: _hovered ? const Color(0x803B82F6) : AppColors.border2,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              if (!widget.isExpanded) ...[
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.smart_toy_outlined,
                      size: 9,
                      color: AppColors.accent,
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      'CHAT WITH SWX AI',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.text2,
                        letterSpacing: 1.0,
                        fontFamily: 'Syne',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── Chat topbar ────────────────────────────────────────────
class _ChatTopbar extends StatelessWidget {
  final VoidCallback onSearch;
  final VoidCallback onExport;
  const _ChatTopbar({required this.onSearch, required this.onExport});

  @override
  Widget build(BuildContext context) {
    // final isLight = context.watch<SettingsProvider>().isLight;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 25),
      decoration: const BoxDecoration(
        color: AppColors.surface, // ← always dark green, regardless of theme
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: AppColors.accentWa,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentWa.withOpacity(0.5),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 13, color: Colors.white70),
                children: [
                  TextSpan(text: "Hello 👋 I'm your "),
                  TextSpan(
                    text: 'Swx AI',
                    style: TextStyle(
                      fontFamily: 'Syne',
                      fontWeight: FontWeight.w700,
                      color: AppColors.accentSoft,
                    ),
                  ),
                  TextSpan(text: '. How can I help you today?'),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Row(
            children: [
              _ActBtn(icon: Icons.search, onTap: onSearch),
              const SizedBox(width: 6),
              _ActBtn(icon: Icons.download_outlined, onTap: onExport),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActBtn extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _ActBtn({required this.icon, required this.onTap});

  @override
  State<_ActBtn> createState() => _ActBtnState();
}

class _ActBtnState extends State<_ActBtn> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: _hovered ? AppColors.accentDim : AppColors.surface2,
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color: _hovered ? const Color(0x4D3B82F6) : AppColors.border,
            ),
          ),
          child: Icon(
            widget.icon,
            size: 14,
            color: _hovered ? AppColors.accent : AppColors.text2,
          ),
        ),
      ),
    );
  }
}

// ── Chat search bar ────────────────────────────────────────
class _ChatSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClose;
  const _ChatSearchBar({
    required this.controller,
    required this.onChanged,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: AppColors.text2, size: 14),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              autofocus: true,
              onChanged: onChanged,
              style: const TextStyle(fontSize: 14, color: AppColors.text),
              decoration: const InputDecoration(
                hintText: 'Search conversation…',
                hintStyle: TextStyle(color: AppColors.text2),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                filled: false,
              ),
            ),
          ),
          GestureDetector(
            onTap: onClose,
            child: const Icon(Icons.close, color: AppColors.text2, size: 16),
          ),
        ],
      ),
    );
  }
}

// ── Messages list ──────────────────────────────────────────
class _MessagesList extends StatelessWidget {
  final List messages;
  final bool isTyping;
  final ScrollController scrollController;
  final String searchQuery;
  const _MessagesList({
    required this.messages,
    required this.isTyping,
    required this.scrollController,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 22),
      itemCount: messages.length + (isTyping ? 1 : 0),
      itemBuilder: (_, i) {
        if (isTyping && i == messages.length) return const TypingIndicator();
        final msg = messages[i];
        if (i == 0) {
          return Column(
            children: [
              ChatDivider(
                label: DateFormat('EEEE, MMMM d').format(DateTime.now()),
              ),
              MessageBubble(message: msg),
            ],
          );
        }
        return MessageBubble(message: msg);
      },
    );
  }
}

// ── Topbar button ──────────────────────────────────────────
class _TopbarBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _TopbarBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.surface2,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, size: 16, color: AppColors.text2),
      ),
    );
  }
}
