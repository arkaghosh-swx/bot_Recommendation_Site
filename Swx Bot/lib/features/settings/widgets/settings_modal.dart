// lib/features/settings/widgets/settings_modal.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../chat/providers/chat_provider.dart';
import '../providers/settings_provider.dart';

// ── Entry point ───────────────────────────────────────────
void showSettingsModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.65),
    builder: (_) => const _SettingsSheet(),
  );
}

class _SettingsSheet extends StatelessWidget {
  const _SettingsSheet();

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
          _ModalHeader(
            icon: Icons.settings_outlined,
            title: 'Settings',
            onClose: () => Navigator.pop(context),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              children: const [
                _SectionTitle('Appearance'),
                SizedBox(height: 14),
                _ThemeRow(),
                SizedBox(height: 14),
                _FontSizeRow(),
                SizedBox(height: 14),
                _BubbleStyleRow(),
                SizedBox(height: 28),
                _SectionTitle('Behaviour'),
                SizedBox(height: 14),
                _SoundRow(),
                SizedBox(height: 14),
                _TypingRow(),
                SizedBox(height: 14),
                _ChipsRow(),
                SizedBox(height: 14),
                _PageSizeRow(),
                SizedBox(height: 28),
                _SectionTitle('Data'),
                SizedBox(height: 14),
                _ExportRow(),
                SizedBox(height: 14),
                _ClearHistoryRow(),
                SizedBox(height: 28),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Modal header (shared with Help) ──────────────────────
class _ModalHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onClose;
  const _ModalHeader({
    required this.icon,
    required this.title,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 16, 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.accent),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
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

// ── Setting row wrapper ───────────────────────────────────
class _SettingRow extends StatelessWidget {
  final String label;
  final String desc;
  final Widget control;
  const _SettingRow({
    required this.label,
    required this.desc,
    required this.control,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: const TextStyle(fontSize: 12, color: AppColors.text2),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        control,
      ],
    );
  }
}

// ── Toggle group (for multi-option settings) ──────────────
class _ToggleGroup<T> extends StatelessWidget {
  final List<T> values;
  final List<String> labels;
  final T selected;
  final ValueChanged<T> onSelect;
  const _ToggleGroup({
    required this.values,
    required this.labels,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(values.length, (i) {
          final isActive = values[i] == selected;
          return GestureDetector(
            onTap: () => onSelect(values[i]),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isActive ? AppColors.accent : Colors.transparent,
                borderRadius: BorderRadius.circular(7),
              ),
              child: Text(
                labels[i],
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'DM Sans',
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isActive ? AppColors.bg : AppColors.text2,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ── Toggle switch (on/off) ────────────────────────────────
class _SettingSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const _SettingSwitch({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 0.85,
      child: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.accent,
        activeTrackColor: AppColors.accentDim,
        inactiveThumbColor: AppColors.text2,
        inactiveTrackColor: AppColors.surface3,
        trackOutlineColor: WidgetStateProperty.all(AppColors.border),
      ),
    );
  }
}

// ── Golden accent value (for local const) ────────────────
// const Color _kAccentColor = Color(0xFF3E7C6B);

// ═══════════════════════════════════════════════════════════
//  APPEARANCE ROWS
// ═══════════════════════════════════════════════════════════

class _ThemeRow extends StatelessWidget {
  const _ThemeRow();
  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsProvider>();
    return _SettingRow(
      label: 'Theme',
      desc: 'Switch between dark and light mode',
      control: _ToggleGroup<AppThemeMode>(
        values: AppThemeMode.values,
        labels: ['Dark', 'Light'],
        selected: s.theme,
        onSelect: (v) {
          s.setTheme(v);
          _toast(context, 'Theme updated ✓');
        },
      ),
    );
  }
}

class _FontSizeRow extends StatelessWidget {
  const _FontSizeRow();
  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsProvider>();
    return _SettingRow(
      label: 'Font Size',
      desc: 'Adjust message text size',
      control: _ToggleGroup<FontSizeMode>(
        values: FontSizeMode.values,
        labels: ['S', 'M', 'L'],
        selected: s.fontSize,
        onSelect: (v) {
          s.setFontSize(v);
          _toast(context, 'Font size updated ✓');
        },
      ),
    );
  }
}

class _BubbleStyleRow extends StatelessWidget {
  const _BubbleStyleRow();
  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsProvider>();
    return _SettingRow(
      label: 'Bubble Style',
      desc: 'Choose message bubble shape',
      control: _ToggleGroup<BubbleStyle>(
        values: BubbleStyle.values,
        labels: ['Rounded', 'Sharp'],
        selected: s.bubble,
        onSelect: (v) {
          s.setBubble(v);
          _toast(context, 'Bubble style updated ✓');
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  BEHAVIOUR ROWS
// ═══════════════════════════════════════════════════════════

class _SoundRow extends StatelessWidget {
  const _SoundRow();
  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsProvider>();
    return _SettingRow(
      label: 'Sound Effects',
      desc: 'Play a sound when a message arrives',
      control: _SettingSwitch(
        value: s.sound,
        onChanged: (v) {
          s.setSound(v);
          _toast(context, v ? 'Sound on 🔔' : 'Sound off 🔕');
        },
      ),
    );
  }
}

class _TypingRow extends StatelessWidget {
  const _TypingRow();
  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsProvider>();
    return _SettingRow(
      label: 'Typing Indicator',
      desc: 'Show animated dots while bot responds',
      control: _SettingSwitch(
        value: s.typing,
        onChanged: (v) {
          s.setTyping(v);
          _toast(context, 'Setting saved ✓');
        },
      ),
    );
  }
}

class _ChipsRow extends StatelessWidget {
  const _ChipsRow();
  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsProvider>();
    return _SettingRow(
      label: 'Quick Questions',
      desc: 'Show suggestion chips after replies',
      control: _SettingSwitch(
        value: s.chips,
        onChanged: (v) {
          s.setChips(v);
          _toast(context, 'Setting saved ✓');
        },
      ),
    );
  }
}

class _PageSizeRow extends StatelessWidget {
  const _PageSizeRow();

  static const _options = [3, 4, 5, 6, 8];

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsProvider>();
    return _SettingRow(
      label: 'Questions Per Page',
      desc: 'Number of chips shown at once',
      control: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.surface2,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<int>(
            value: s.pageSize,
            dropdownColor: AppColors.surface2,
            iconEnabledColor: AppColors.text2,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.text,
              fontFamily: 'DM Sans',
            ),
            items: _options.map((n) {
              return DropdownMenuItem(value: n, child: Text('$n'));
            }).toList(),
            onChanged: (v) {
              if (v != null) {
                s.setPageSize(v);
                _toast(context, 'Setting saved ✓');
              }
            },
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  DATA ROWS
// ═══════════════════════════════════════════════════════════

class _ExportRow extends StatelessWidget {
  const _ExportRow();
  @override
  Widget build(BuildContext context) {
    return _SettingRow(
      label: 'Export Chat',
      desc: 'Share the current conversation as text',
      control: _ActionButton(
        icon: Icons.download_outlined,
        label: 'Export',
        onTap: () {
          final chat = context.read<ChatProvider>();
          final text = chat.exportChatText();
          if (text.isEmpty) {
            _toast(context, 'Nothing to export yet.');
            return;
          }
          Navigator.pop(context);
          Share.share(text, subject: 'Sol — Chat Export'); // ← uncomment
          _toast(context, 'Chat exported 📄');
        },
      ),
    );
  }
}

class _ClearHistoryRow extends StatelessWidget {
  const _ClearHistoryRow();
  @override
  Widget build(BuildContext context) {
    return _SettingRow(
      label: 'Clear All History',
      desc: 'Remove all saved sessions permanently',
      control: _ActionButton(
        icon: Icons.delete_outline,
        label: 'Clear',
        isDanger: true,
        onTap: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (_) => AlertDialog(
              backgroundColor: AppColors.surface2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                'Clear all history?',
                style: TextStyle(
                  fontFamily: 'Syne',
                  color: AppColors.text,
                  fontSize: 16,
                ),
              ),
              content: const Text(
                'This will permanently delete all chat sessions. This cannot be undone.',
                style: TextStyle(color: AppColors.text2, fontSize: 13),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: AppColors.text2),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text(
                    'Delete',
                    style: TextStyle(color: Color(0xFFD66B6B)),
                  ),
                ),
              ],
            ),
          );
          if (confirm == true && context.mounted) {
            final chat = context.read<ChatProvider>();
            while (chat.sessions.length > 1) {
              chat.deleteSession(chat.sessions.last);
            }
            chat.startNewChat();
            Navigator.pop(context);
            _toast(context, 'All history cleared 🗑️');
          }
        },
      ),
    );
  }
}

// ── Shared action button ──────────────────────────────────
class _ActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDanger;
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDanger = false,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final dangerColor = const Color(0xFFD66B6B);
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: _hovered
                ? (widget.isDanger
                      ? dangerColor.withOpacity(0.1)
                      : AppColors.accentDim)
                : AppColors.surface2,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _hovered
                  ? (widget.isDanger ? dangerColor : AppColors.accent)
                  : AppColors.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                size: 13,
                color: widget.isDanger ? dangerColor : AppColors.text,
              ),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 13,
                  fontFamily: 'DM Sans',
                  color: widget.isDanger ? dangerColor : AppColors.text,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Toast helper (local) ──────────────────────────────────
void _toast(BuildContext context, String msg) {
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
