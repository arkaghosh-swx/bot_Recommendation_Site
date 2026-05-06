// lib/features/chat/widgets/message_bubble.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import 'package:sol_bot/features/settings/providers/settings_provider.dart';

import '../models/chat_message.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool showAvatar;

  const MessageBubble({
    super.key,
    required this.message,
    this.showAvatar = true,
  });

  bool get isUser => message.role == MessageRole.user;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[_Avatar(isUser: false), const SizedBox(width: 10)],
          Flexible(
            child: Column(
              crossAxisAlignment: isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                _Bubble(message: message, isUser: isUser),
                const SizedBox(height: 4),
                _Meta(message: message, isUser: isUser),
              ],
            ),
          ),
          if (isUser) ...[const SizedBox(width: 10), _Avatar(isUser: true)],
        ],
      ),
    );
  }
}

// ── Avatar ────────────────────────────────────────────────
class _Avatar extends StatelessWidget {
  final bool isUser;
  const _Avatar({required this.isUser});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        gradient: isUser ? null : AppColors.botAvatarGrad,
        color: isUser ? AppColors.surface3 : null,
        borderRadius: BorderRadius.circular(9),
        border: isUser ? Border.all(color: AppColors.border2) : null,
      ),
      child: Center(
        child: Text(
          isUser ? 'U' : 'AI',
          style: TextStyle(
            fontFamily: 'Syne',
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: isUser ? AppColors.text2 : Colors.white,
          ),
        ),
      ),
    );
  }
}

// ── Bubble ────────────────────────────────────────────────
class _Bubble extends StatelessWidget {
  final ChatMessage message;
  final bool isUser;

  const _Bubble({required this.message, required this.isUser});

  @override
  Widget build(BuildContext context) {
    // ADD these two lines at the top
    final settings = context.watch<SettingsProvider>();
    final isLight = settings.isLight;
    final fontSize = settings.messageFontSize;
    final radius = settings.bubbleRadius;
    final tailRadius = settings.bubbleTailRadius;

    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.72,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 13),
      decoration: BoxDecoration(
        gradient: isUser ? AppColors.grad : null,
        color: isUser
            ? null
            : (isLight ? AppColors.lightSurface2 : AppColors.surface2),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(radius),
          topRight: Radius.circular(radius),
          bottomLeft: isUser
              ? Radius.circular(radius)
              : Radius.circular(tailRadius),
          bottomRight: isUser
              ? Radius.circular(tailRadius)
              : Radius.circular(radius),
        ),
        border: isUser ? null : Border.all(color: AppColors.border),
      ),
      child: isUser
          ? Text(
              message.text,
              style: TextStyle(
                // ← was const, now dynamic
                fontSize: fontSize,
                color: Colors.white,
                height: 1.65,
              ),
            )
          : MarkdownBody(
              data: message.text,
              styleSheet: MarkdownStyleSheet(
                p: TextStyle(
                  fontSize: fontSize,
                  color: isLight
                      ? AppColors.lightText
                      : AppColors.text, // ← fix
                  height: 1.65,
                ),
                // Fix strong, h1, h2, h3 colors too:
                strong: TextStyle(
                  color: isLight ? AppColors.lightText : Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                h1: TextStyle(
                  fontFamily: 'Syne',
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: isLight ? AppColors.lightText : Colors.white,
                ),
                h2: TextStyle(
                  fontFamily: 'Syne',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isLight ? AppColors.lightText : Colors.white,
                ),
                h3: TextStyle(
                  fontFamily: 'Syne',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isLight ? AppColors.lightText : Colors.white,
                ),
                code: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  color: AppColors.accent,
                  backgroundColor: AppColors.accentDim,
                ),
                blockquotePadding: const EdgeInsets.only(left: 12),
                blockquoteDecoration: const BoxDecoration(
                  border: Border(
                    left: BorderSide(color: AppColors.accent, width: 3),
                  ),
                ),
                listBullet: const TextStyle(color: AppColors.text2),
                a: TextStyle(color: AppColors.accent),
                tableHead: TextStyle(
                  fontFamily: 'Syne',
                  color: AppColors.accent,
                  fontWeight: FontWeight.w700,
                ),
                tableBody: const TextStyle(color: AppColors.text),
                tableBorder: TableBorder.all(color: AppColors.border2),
                tableHeadAlign: TextAlign.left,
              ),
            ),
    );
  }
}

// ── Meta row (time + copy) ────────────────────────────────
class _Meta extends StatelessWidget {
  final ChatMessage message;
  final bool isUser;

  const _Meta({required this.message, required this.isUser});

  @override
  Widget build(BuildContext context) {
    final isLight = context.watch<SettingsProvider>().isLight;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          message.formattedTime,
          style: TextStyle(
            fontSize: 11,
            color: isLight ? AppColors.lightText2 : AppColors.text2,
          ),
        ),
        if (!isUser) ...[
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: message.text));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Copied ✓'),
                  duration: Duration(
                    milliseconds: AppConstants.toastDurationMs,
                  ),
                  backgroundColor: AppColors.surface3,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              );
            },
            child: Row(
              children: [
                Icon(
                  Icons.copy,
                  size: 12,
                  color: isLight ? AppColors.lightText2 : AppColors.text2,
                ),
                Text(
                  'Copy',
                  style: TextStyle(
                    fontSize: 11,
                    color: isLight ? AppColors.lightText2 : AppColors.text2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
