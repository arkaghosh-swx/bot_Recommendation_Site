// lib/features/sidebar/widgets/app_sidebar.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../chat/providers/chat_provider.dart';
import '../../chat/models/chat_session.dart';

class AppSidebar extends StatefulWidget {
  const AppSidebar({super.key});

  @override
  State<AppSidebar> createState() => _AppSidebarState();
}

class _AppSidebarState extends State<AppSidebar> {
  bool _quickActionsExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chat, _) {
        return Container(
          width: 288,
          color: AppColors.surface,
          child: Column(
            children: [
              // ── Inner (scrollable) ──────────────────────
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 24, 18, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Close button (mobile)
                      if (MediaQuery.of(context).size.width < 768)
                        Align(
                          alignment: Alignment.topRight,
                          child: GestureDetector(
                            onTap: chat.closeSidebar,
                            child: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: AppColors.surface3,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.close,
                                color: AppColors.text,
                                size: 18,
                              ),
                            ),
                          ),
                        ),

                      // ── Brand ─────────────────────────────
                      _Brand(),
                      const SizedBox(height: 14),

                      // ── New Chat Button ───────────────────
                      _NewChatBtn(onTap: () => chat.startNewChat()),
                      const SizedBox(height: 14),

                      // ── History List ──────────────────────
                      Expanded(
                        child: _HistoryList(
                          sessions: chat.sessions,
                          activeId: chat.activeSession?.id,
                          onLoad: chat.loadSession,
                          onDelete: chat.deleteSession,
                          onRename: (s) => _showRenameDialog(context, chat, s),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Footer ──────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: AppColors.border)),
                ),
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
                child: Column(
                  children: [
                    // Quick actions accordion
                    _QuickActionsSection(
                      expanded: _quickActionsExpanded,
                      onToggle: () => setState(
                        () => _quickActionsExpanded = !_quickActionsExpanded,
                      ),
                      chat: chat,
                    ),
                    const SizedBox(height: 8),
                    // Back to website
                    GestureDetector(
                      onTap: () {
                        /* url_launcher → website */
                      },
                      child: Row(
                        children: [
                          
                          const SizedBox(width: 8),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showRenameDialog(
    BuildContext context,
    ChatProvider chat,
    ChatSession session,
  ) {
    final ctrl = TextEditingController(text: session.label);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Rename conversation',
          style: TextStyle(color: AppColors.text, fontFamily: 'Syne'),
        ),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: const TextStyle(color: AppColors.text),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surface3,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.text2),
            ),
          ),
          TextButton(
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) {
                chat.renameSession(session, ctrl.text.trim());
              }
              Navigator.pop(context);
            },
            child: Text('Save', style: TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
    );
  }
}

// ── Brand mark ─────────────────────────────────────────────
class _Brand extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(13),
          ),
          child: const Center(
            child: Text(
              'W',
              style: TextStyle(
                fontFamily: 'Syne',
                fontWeight: FontWeight.w800,
                fontSize: 20,
                color: AppColors.bg,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sol',
              style: TextStyle(
                fontFamily: 'Syne',
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: AppColors.text,
              ),
            ),
            const Text(
              'Your Health Assistant',
              style: TextStyle(fontSize: 11.5, color: AppColors.text2),
            ),
          ],
        ),
      ],
    );
  }
}

// ── New Chat Button ────────────────────────────────────────
class _NewChatBtn extends StatelessWidget {
  final VoidCallback onTap;
  const _NewChatBtn({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          gradient: AppColors.grad,
          borderRadius: BorderRadius.circular(13),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withOpacity(0.25),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.add, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            const Text(
              'New Conversation',
              style: TextStyle(
                fontFamily: 'Syne',
                fontWeight: FontWeight.w700,
                fontSize: 13.5,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── History List ───────────────────────────────────────────
class _HistoryList extends StatelessWidget {
  final List<ChatSession> sessions;
  final String? activeId;
  final ValueChanged<ChatSession> onLoad;
  final ValueChanged<ChatSession> onDelete;
  final ValueChanged<ChatSession> onRename;

  const _HistoryList({
    required this.sessions,
    required this.activeId,
    required this.onLoad,
    required this.onDelete,
    required this.onRename,
  });

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) {
      return const Center(
        child: Text(
          'No conversations yet',
          style: TextStyle(fontSize: 12, color: AppColors.text2),
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.separated(
      itemCount: sessions.length,
      separatorBuilder: (_, _) => const SizedBox(height: 4),
      itemBuilder: (_, i) {
        final s = sessions[i];
        final isActive = s.id == activeId;
        return _HistoryItem(
          session: s,
          isActive: isActive,
          onLoad: onLoad,
          onDelete: onDelete,
          onRename: onRename,
        );
      },
    );
  }
}

class _HistoryItem extends StatefulWidget {
  final ChatSession session;
  final bool isActive;
  final ValueChanged<ChatSession> onLoad;
  final ValueChanged<ChatSession> onDelete;
  final ValueChanged<ChatSession> onRename;

  const _HistoryItem({
    required this.session,
    required this.isActive,
    required this.onLoad,
    required this.onDelete,
    required this.onRename,
  });

  @override
  State<_HistoryItem> createState() => _HistoryItemState();
}

class _HistoryItemState extends State<_HistoryItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => widget.onLoad(widget.session),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: widget.isActive
                ? const Color(0x113B82F6)
                : _hovered
                ? AppColors.surface3
                : AppColors.surface2,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: widget.isActive
                  ? const Color(0x4D3B82F6)
                  : _hovered
                  ? AppColors.border2
                  : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.session.label,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: widget.isActive
                        ? AppColors.accent
                        : _hovered
                        ? AppColors.text
                        : AppColors.text2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  maxLines: 1,
                ),
              ),
              if (_hovered || widget.isActive) ...[
                const SizedBox(width: 4),
                _HistActionBtn(
                  icon: Icons.edit,
                  onTap: () => widget.onRename(widget.session),
                ),
                const SizedBox(width: 2),
                _HistActionBtn(
                  icon: Icons.delete_outline,
                  onTap: () => widget.onDelete(widget.session),
                  isDelete: true,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _HistActionBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isDelete;

  const _HistActionBtn({
    required this.icon,
    required this.onTap,
    this.isDelete = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: Colors.transparent,
        ),
        child: Icon(
          icon,
          size: 12,
          color: isDelete ? AppColors.red : AppColors.text2,
        ),
      ),
    );
  }
}

// ── Quick Actions Section ──────────────────────────────────
class _QuickActionsSection extends StatelessWidget {
  final bool expanded;
  final VoidCallback onToggle;
  final ChatProvider chat;

  const _QuickActionsSection({
    required this.expanded,
    required this.onToggle,
    required this.chat,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Toggle header
        GestureDetector(
          onTap: onToggle,
          child: Container(
            color: Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 12),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'QUICK ACTIONS',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.text2,
                      letterSpacing: 1.4,
                      fontFamily: 'DM Sans',
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: const Icon(
                    Icons.keyboard_arrow_down,
                    size: 16,
                    color: AppColors.text2,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Expanded items
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: expanded
              ? Column(
                  children: AppConstants.quickActions.map((action) {
                    return _NavItem(
                      label: action['label']!,
                      onTap: () => chat.sendMessage(action['question']!),
                    );
                  }).toList(),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _NavItem extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const _NavItem({required this.label, required this.onTap});

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
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
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 11),
          margin: const EdgeInsets.symmetric(vertical: 1.5),
          decoration: BoxDecoration(
            color: _hovered ? AppColors.surface2 : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(
              color: _hovered ? AppColors.border2 : Colors.transparent,
            ),
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: 13,
              color: _hovered ? AppColors.text : AppColors.text2,
            ),
          ),
        ),
      ),
    );
  }
}
