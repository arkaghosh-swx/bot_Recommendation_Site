// lib/features/chat/widgets/reco_bar.dart

import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class RecoBar extends StatelessWidget {
  final List<String> chips;
  final ValueChanged<String> onChipTap;

  const RecoBar({super.key, required this.chips, required this.onChipTap});

  @override
  Widget build(BuildContext context) {
    if (chips.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Label
          Row(
            children: [
              const Icon(Icons.auto_awesome, size: 12, color: AppColors.accent),
              const SizedBox(width: 5),
              Text(
                'YOU MIGHT ALSO ASK:',
                style: TextStyle(
                  fontFamily: 'Syne',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accent,
                  letterSpacing: 0.08 * 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Chips
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: chips
                .map((chip) => _RecoChip(label: chip, onTap: onChipTap))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _RecoChip extends StatefulWidget {
  final String label;
  final ValueChanged<String> onTap;

  const _RecoChip({required this.label, required this.onTap});

  @override
  State<_RecoChip> createState() => _RecoChipState();
}

class _RecoChipState extends State<_RecoChip> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => widget.onTap(widget.label),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _hovered ? AppColors.accentDim : AppColors.surface3,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: _hovered ? AppColors.accent : AppColors.border2,
            ),
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: 12,
              color: _hovered ? AppColors.accent : AppColors.text,
              fontFamily: 'DM Sans',
            ),
          ),
        ),
      ),
    );
  }
}
