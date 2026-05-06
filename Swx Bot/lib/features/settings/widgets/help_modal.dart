// lib/features/settings/widgets/help_modal.dart

import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';

// ── Entry point ───────────────────────────────────────────
void showHelpModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.65),
    builder: (_) => const _HelpSheet(),
  );
}

class _HelpSheet extends StatelessWidget {
  const _HelpSheet();

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return Container(
      height: mq.size.height * 0.88,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.fromBorderSide(BorderSide(color: AppColors.border2)),
      ),

      child: Column(
        children: [
          _ModalHeader(onClose: () => Navigator.pop(context)),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              children: const [
                // About
                _SectionTitle('About Swx Bot'),
                SizedBox(height: 14),
                _AboutCard(),
                SizedBox(height: 28),

                // How to use
                _SectionTitle('How to Use'),
                SizedBox(height: 14),
                _HowToUseSteps(),
                SizedBox(height: 28),

                // Shortcuts
                _SectionTitle('Keyboard Shortcuts'),
                SizedBox(height: 14),
                _ShortcutsGrid(),
                SizedBox(height: 28),

                // FAQ
                _SectionTitle('FAQ'),
                SizedBox(height: 14),
                _FaqList(),
                SizedBox(height: 28),

                // Contact
                _SectionTitle('Still Need Help?'),
                SizedBox(height: 14),
                _ContactCards(),
                SizedBox(height: 28),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Modal header ──────────────────────────────────────────
class _ModalHeader extends StatelessWidget {
  final VoidCallback onClose;
  const _ModalHeader({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 16, 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          const Icon(Icons.help_outline, size: 18, color: AppColors.accent),
          const SizedBox(width: 10),
          const Text(
            'Help & Info',
            style: TextStyle(
              fontFamily: 'Syne',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.accent,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onClose,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.surface2,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(Icons.close, size: 14, color: AppColors.text2),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section title ─────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String label;
  const _SectionTitle(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          letterSpacing: 1.2,
          color: AppColors.accent,
          fontWeight: FontWeight.w600,
          fontFamily: 'Syne',
        ),
      ),
    );
  }
}

// ── About card ────────────────────────────────────────────
class _AboutCard extends StatelessWidget {
  const _AboutCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: AppColors.botAvatarGrad,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'AI',
                style: TextStyle(
                  fontFamily: 'Syne',
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${AppConstants.botName} — ${AppConstants.clinicName}',
                  style: const TextStyle(
                    fontFamily: 'Syne',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Your always-on health assistant. Ask anything about treatments, consultations, conditions, or how homoeopathy can help you.',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: AppColors.text2,
                    height: 1.55,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── How to use steps ──────────────────────────────────────
class _HowToUseSteps extends StatelessWidget {
  const _HowToUseSteps();

  static const _steps = [
    (
      title: 'Type a question',
      desc:
          'Use the input box at the bottom of the chat and tap the send button.',
    ),
    (
      title: 'Tap a quick chip',
      desc:
          'Pre-loaded suggestion chips appear after each reply for instant answers.',
    ),
    (
      title: 'Browse topics',
      desc:
          'Tap the suggestion chips to explore conditions, consultations, and more.',
    ),
    (
      title: 'Start a new chat',
      desc:
          'Use "+ New Conversation" in the sidebar anytime. Past sessions are saved.',
    ),
    (
      title: 'Search conversation',
      desc: 'Use the 🔍 icon in the chat header to find past messages quickly.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _steps.asMap().entries.map((e) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.accentDim,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0x383E7C6B)),
                ),
                child: Center(
                  child: Text(
                    '${e.key + 1}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.accent,
                      fontFamily: 'Syne',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      e.value.title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      e.value.desc,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.text2,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ── Shortcuts grid ────────────────────────────────────────
class _ShortcutsGrid extends StatelessWidget {
  const _ShortcutsGrid();

  static const _shortcuts = [
    (keys: ['Enter'], desc: 'Send message'),
    (keys: ['Ctrl', 'K'], desc: 'Toggle search'),
    (keys: ['Ctrl', 'N'], desc: 'New chat'),
    (keys: ['Esc'], desc: 'Close panel / search'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: _shortcuts.asMap().entries.map((e) {
          final isLast = e.key == _shortcuts.length - 1;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: isLast
                  ? null
                  : const Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Wrap(
                  spacing: 4,
                  children: e.value.keys.map((k) => _Kbd(label: k)).toList(),
                ),
                const SizedBox(width: 12),
                Text(
                  e.value.desc,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.text2,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _Kbd extends StatelessWidget {
  final String label;
  const _Kbd({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.surface3,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: AppColors.border2),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontFamily: 'monospace',
          color: AppColors.text,
        ),
      ),
    );
  }
}

// ── FAQ list ──────────────────────────────────────────────
class _FaqList extends StatelessWidget {
  const _FaqList();

  static const _faqs = [
    (
      q: "Why isn't Swx answering my question?",
      a: 'Swx can only answer questions in its knowledge base. Try rephrasing your question or tap a suggestion chip for supported topics.',
    ),
    (
      q: 'Is this conversation private?',
      a: 'Conversations are stored locally on your device only. No personal data is sent externally beyond the query to our AI service.',
    ),
    (
      q: 'How do I talk to a human?',
      a: 'Type "human" or "speak to someone" in the chat and Swx will provide escalation contact details for the clinic.',
    ),
    (
      q: 'Can I export my conversation?',
      a: 'Yes! Go to Settings → Data → Export Chat to share the current conversation as a text file.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _faqs
          .map((faq) => _FaqItem(question: faq.q, answer: faq.a))
          .toList(),
    );
  }
}

class _FaqItem extends StatefulWidget {
  final String question;
  final String answer;
  const _FaqItem({required this.question, required this.answer});

  @override
  State<_FaqItem> createState() => _FaqItemState();
}

class _FaqItemState extends State<_FaqItem>
    with SingleTickerProviderStateMixin {
  bool _open = false;
  late final AnimationController _ctrl;
  late final Animation<double> _expand;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _expand = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _open = !_open);
    _open ? _ctrl.forward() : _ctrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: _toggle,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.question,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.text,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: _open ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
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
          SizeTransition(
            sizeFactor: _expand,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 13),
              child: Text(
                widget.answer,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.text2,
                  height: 1.6,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Contact cards ─────────────────────────────────────────
class _ContactCards extends StatelessWidget {
  const _ContactCards();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ContactCard(
            icon: Icons.email_outlined,
            title: 'Email Support',
            subtitle: 'support@warriorhomoeopath.com',
            onTap: () {
              // url_launcher: launchUrl(Uri.parse('mailto:support@...'))
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ContactCard(
            icon: Icons.phone_outlined,
            title: 'Call Us',
            subtitle: 'Mon–Fri, 9am–6pm',
            onTap: () {
              // url_launcher: launchUrl(Uri.parse('tel:+91...'))
            },
          ),
        ),
      ],
    );
  }
}

class _ContactCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _ContactCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  State<_ContactCard> createState() => _ContactCardState();
}

class _ContactCardState extends State<_ContactCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _hovered ? AppColors.accentDim : AppColors.surface2,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _hovered ? AppColors.accent : AppColors.border,
            ),
          ),
          child: Column(
            children: [
              Icon(widget.icon, size: 22, color: AppColors.accent),
              const SizedBox(height: 6),
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.text,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                widget.subtitle,
                style: const TextStyle(fontSize: 11, color: AppColors.text2),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
