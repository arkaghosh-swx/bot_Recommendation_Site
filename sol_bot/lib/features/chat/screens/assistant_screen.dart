// lib/features/chat/screens/assistant_screen.dart

import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';

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

  // Drawer drag state — mirrors JS initDrag()
  double _drawerHeight = 112;
  double _dragStartY = 0;
  double _dragStartH = 0;
  bool _isDragging = false;

  late AnimationController _drawerAnim;

  // Chat search
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();

    _drawerAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    // Initialise provider after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().init();
      _setDrawerPeek();
    });

    // Focus expanding drawer (mirrors JS inputEl.addEventListener('focus'))
    _inputFocus.addListener(() {
      if (_inputFocus.hasFocus) {
        context.read<ChatProvider>().expandDrawer();
      }
    });
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _msgScroll.dispose();
    _mainScroll.dispose();
    _inputFocus.dispose();
    _searchCtrl.dispose();
    _drawerAnim.dispose();
    super.dispose();
  }

  void _setDrawerPeek() {
    // peek = 72 + 40 (handle h) = 112px
    setState(() => _drawerHeight = 112);
  }

  double get _maxDrawerHeight {
    final screenH = MediaQuery.of(context).size.height;
    final topBarH = MediaQuery.of(context).size.width < 768 ? 58.0 : 0.0;
    return screenH - topBarH;
  }

  void _expandDrawer() {
    setState(() => _drawerHeight = _maxDrawerHeight);
    context.read<ChatProvider>().expandDrawer();
  }

  void _collapseDrawer() {
    _setDrawerPeek();
    context.read<ChatProvider>().collapseDrawer();
  }

  void _toggleDrawer() {
    if (context.read<ChatProvider>().drawerExpanded) {
      _collapseDrawer();
    } else {
      _expandDrawer();
    }
  }

  void _onDragStart(DragStartDetails d) {
    _isDragging = true;
    _dragStartY = d.globalPosition.dy;
    _dragStartH = _drawerHeight;
  }

  void _onDragUpdate(DragUpdateDetails d) {
    if (!_isDragging) return;
    final delta = _dragStartY - d.globalPosition.dy; // positive = drag up
    final newH = (_dragStartH + delta).clamp(112.0, _maxDrawerHeight);
    setState(() => _drawerHeight = newH);
  }

  void _onDragEnd(DragEndDetails d) {
    if (!_isDragging) return;
    _isDragging = false;

    // Snap: dragged > 80px up → expand; > 40px down → collapse
    if (_drawerHeight > _maxDrawerHeight * 0.55) {
      _expandDrawer();
    } else {
      _collapseDrawer();
    }
  }

  void _sendMessage() {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) return;
    _inputCtrl.clear();
    context.read<ChatProvider>().sendMessage(text).then((_) {
      _scrollToBottom();
    });
    _expandDrawer();
    _scrollToBottom();
  }

  void _quickAsk(String question) {
    _inputCtrl.text = question;
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
    await Share.share(text, subject: 'Sol — Chat Export');
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 768;

    return Consumer<ChatProvider>(
      builder: (context, chat, _) {
        // Keep drawer in sync with provider
        if (chat.drawerExpanded && _drawerHeight < _maxDrawerHeight * 0.9) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && chat.drawerExpanded) {
              setState(() => _drawerHeight = _maxDrawerHeight);
            }
          });
        }

        // Scroll to bottom when new messages arrive
        if (chat.messages.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => _scrollToBottom(),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.bg,
          body: AppBackground(child: _buildLayout(context, chat, isMobile)),
        );
      },
    );
  }

  Widget _buildLayout(BuildContext ctx, ChatProvider chat, bool isMobile) {
    if (isMobile) {
      return _buildMobileLayout(ctx, chat);
    } else {
      return _buildDesktopLayout(ctx, chat);
    }
  }

  // ── Desktop layout (sidebar + main) ───────────────────────
  Widget _buildDesktopLayout(BuildContext ctx, ChatProvider chat) {
    return Row(
      children: [
        const AppSidebar(),
        // Right edge glow line
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
        Expanded(child: _buildMain(ctx, chat, isMobile: false)),
      ],
    );
  }

  // ── Mobile layout (drawer sidebar overlay) ────────────────
  Widget _buildMobileLayout(BuildContext ctx, ChatProvider chat) {
    return Stack(
      children: [
        Column(
          children: [
            _buildTopbar(chat),
            Expanded(child: _buildMain(ctx, chat, isMobile: true)),
          ],
        ),
        // Sidebar overlay
        if (chat.sidebarOpen) ...[
          GestureDetector(
            onTap: chat.closeSidebar,
            child: Container(color: Colors.black54),
          ),
          const Positioned(left: 0, top: 0, bottom: 0, child: AppSidebar()),
        ],
      ],
    );
  }

  // ── Mobile topbar ─────────────────────────────────────────
  Widget _buildTopbar(ChatProvider chat) {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
            'Sol AI',
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

  // ── Main content area ─────────────────────────────────────
  Widget _buildMain(
    BuildContext ctx,
    ChatProvider chat, {
    required bool isMobile,
  }) {
    return Stack(
      children: [
        // Scrollable hero + suggestion cards
        AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: chat.drawerExpanded ? 0 : 1,
          child: IgnorePointer(
            ignoring: chat.drawerExpanded,
            child: SingleChildScrollView(
              controller: _mainScroll,
              child: Column(
                children: [
                  const HeroSection(),
                  SuggestionCards(onCardTap: _quickAsk),
                  // Bottom padding so content clears the chat shell
                  const SizedBox(height: 112 + 40),
                ],
              ),
            ),
          ),
        ),

        // ── Chat Shell (bottom drawer) ──────────────────────
        _buildChatShell(chat, isMobile),
      ],
    );
  }

  // ── Chat Shell ────────────────────────────────────────────
  Widget _buildChatShell(ChatProvider chat, bool isMobile) {
    final showExpandedContent = chat.drawerExpanded && _drawerHeight > 260;
    final showSearchBar = chat.searchBarOpen && _drawerHeight > 320;
    final showRecoBar = chat.showRecoBar && _drawerHeight > 340;
    final showComposer = _drawerHeight > 240;

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: GestureDetector(
        onVerticalDragStart: _onDragStart,
        onVerticalDragUpdate: _onDragUpdate,
        onVerticalDragEnd: _onDragEnd,
        child: AnimatedContainer(
          duration: _isDragging
              ? Duration.zero
              : const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          height: _drawerHeight,
          constraints: BoxConstraints(
            minHeight: 140,
            maxHeight: _maxDrawerHeight,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
            child: chat.drawerExpanded
                ? Column(
                    children: [
                      _DrawerHandle(
                        isExpanded: chat.drawerExpanded,
                        onTap: _toggleDrawer,
                      ),

                      if (showExpandedContent) ...[
                        _ChatTopbar(
                          onSearch: () {
                            chat.toggleSearchBar();
                            if (chat.searchBarOpen) {
                              Future.delayed(
                                const Duration(milliseconds: 50),
                                () => _searchCtrl.clear(),
                              );
                            }
                          },
                          onExport: _exportChat,
                        ),

                        if (showSearchBar)
                          Flexible(
                            flex: 0,
                            child: _ChatSearchBar(
                              controller: _searchCtrl,
                              onChanged: chat.updateSearch,
                              onClose: () {
                                chat.toggleSearchBar();
                                _searchCtrl.clear();
                              },
                            ),
                          ),

                        Expanded(
                          child: _MessagesList(
                            messages: _filteredMessages(chat),
                            isTyping: chat.isTyping,
                            scrollController: _msgScroll,
                            searchQuery: chat.searchQuery,
                          ),
                        ),

                        if (showRecoBar)
                          Flexible(
                            flex: 0,
                            child: RecoBar(
                              chips: chat.recoChips,
                              onChipTap: _quickAsk,
                            ),
                          ),

                        if (showComposer) // 👈 CRITICAL FIX
                          ChatComposer(
                            controller: _inputCtrl,
                            onSend: _sendMessage,
                            disabled: chat.isTyping,
                            focusNode: _inputFocus,
                          ),
                      ],
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _DrawerHandle(
                        isExpanded: chat.drawerExpanded,
                        onTap: _toggleDrawer,
                      ),
                    ],
                  ),
          ),
        ),
      ),
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
        child: Container(
          height: 36,
          color: Colors.transparent,
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
                const SizedBox(height: 4),
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
                      'CHAT WITH SOL AI',
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          // Status dot
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
                style: TextStyle(fontSize: 13, color: AppColors.text2),
                children: [
                  TextSpan(text: "Hello 👋 I'm your "),
                  TextSpan(
                    text: 'Sol AI',
                    style: TextStyle(
                      fontFamily: 'Syne',
                      fontWeight: FontWeight.w700,
                      color: AppColors.accent,
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
        if (isTyping && i == messages.length) {
          return const TypingIndicator();
        }
        final msg = messages[i];
        // Show date divider at first message
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
