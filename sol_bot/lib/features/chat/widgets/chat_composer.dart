// lib/features/chat/widgets/chat_composer.dart

import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class ChatComposer extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool disabled;
  final FocusNode? focusNode;

  const ChatComposer({
    super.key,
    required this.controller,
    required this.onSend,
    this.disabled = false,
    this.focusNode,
  });

  @override
  State<ChatComposer> createState() => _ChatComposerState();
}

class _ChatComposerState extends State<ChatComposer> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Input row
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              decoration: BoxDecoration(
                color: AppColors.surface2,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _focused ? const Color(0x663B82F6) : AppColors.border2,
                  width: _focused ? 1.5 : 1,
                ),
                boxShadow: _focused
                    ? [
                        BoxShadow(
                          color: const Color(0xFF3B82F6).withOpacity(0.08),
                          blurRadius: 0,
                          spreadRadius: 3,
                        ),
                      ]
                    : [],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Focus(
                      onFocusChange: (f) => setState(() => _focused = f),
                      child: TextField(
                        controller: widget.controller,
                        focusNode: widget.focusNode,
                        maxLines: 5,
                        minLines: 1,
                        enabled: !widget.disabled,
                        textInputAction: TextInputAction.newline,
                        keyboardType: TextInputType.multiline,
                        style: const TextStyle(
                          fontSize: 14.5,
                          color: AppColors.text,
                          height: 1.6,
                        ),
                        decoration: const InputDecoration(
                          hintText:
                              'Ask about treatment, consultation, or your condition…',
                          hintStyle: TextStyle(
                            fontSize: 14.5,
                            color: AppColors.text2,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.fromLTRB(16, 8, 8, 8),
                          filled: false,
                        ),
                        onSubmitted: (_) => widget.onSend(),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: GestureDetector(
                      onTap: widget.disabled ? null : widget.onSend,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: widget.disabled ? null : AppColors.grad,
                          color: widget.disabled ? AppColors.surface3 : null,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: widget.disabled
                              ? []
                              : [
                                  BoxShadow(
                                    color: AppColors.accent.withOpacity(0.3),
                                    blurRadius: 18,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                        ),
                        child: Icon(
                          Icons.send_rounded,
                          size: 18,
                          color: widget.disabled
                              ? AppColors.text2.withOpacity(0.4)
                              : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
