// lib/features/chat/widgets/chat_divider.dart

import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class ChatDivider extends StatelessWidget {
  final String label;
  const ChatDivider({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Container(height: 1, color: AppColors.border)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              label,
              style: const TextStyle(fontSize: 11, color: AppColors.text2),
            ),
          ),
          Expanded(child: Container(height: 1, color: AppColors.border)),
        ],
      ),
    );
  }
}
