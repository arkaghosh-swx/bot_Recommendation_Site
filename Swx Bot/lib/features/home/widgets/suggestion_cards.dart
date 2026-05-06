// lib/features/home/widgets/suggestion_cards.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';

class SuggestionCards extends StatelessWidget {
  final ValueChanged<String> onCardTap;

  const SuggestionCards({super.key, required this.onCardTap});

  IconData _iconFor(String key) {
    switch (key) {
      case 'doctor':
        return Icons.medical_services_outlined;
      case 'video':
        return Icons.videocam_outlined;
      case 'heart':
        return Icons.favorite_outline;
      case 'calendar':
        return Icons.calendar_today_outlined;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Container(
      padding: EdgeInsets.all(
        isMobile ? 14 : 28,
      ).copyWith(left: isMobile ? 18 : 48, right: isMobile ? 18 : 48),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: isMobile
          ? Column(
              children: AppConstants.suggestionCards.asMap().entries.map((e) {
                final delay = Duration(milliseconds: 100 + e.key * 50);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _SuggCard(
                    card: e.value,
                    icon: _iconFor(e.value['icon']!),
                    onTap: onCardTap,
                  ).animate().fadeIn(delay: delay).slideY(begin: 0.3),
                );
              }).toList(),
            )
          : GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 3.2,
              children: AppConstants.suggestionCards.asMap().entries.map((e) {
                final delay = Duration(milliseconds: 100 + e.key * 50);
                return _SuggCard(
                  card: e.value,
                  icon: _iconFor(e.value['icon']!),
                  onTap: onCardTap,
                ).animate().fadeIn(delay: delay).slideY(begin: 0.3);
              }).toList(),
            ),
    );
  }
}

class _SuggCard extends StatefulWidget {
  final Map<String, String> card;
  final IconData icon;
  final ValueChanged<String> onTap;

  const _SuggCard({
    required this.card,
    required this.icon,
    required this.onTap,
  });

  @override
  State<_SuggCard> createState() => _SuggCardState();
}

class _SuggCardState extends State<_SuggCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => widget.onTap(widget.card['question']!),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: _hovered ? AppColors.surface2 : AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _hovered ? const Color(0x4D3B82F6) : AppColors.border,
            ),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 32,
                      offset: const Offset(0, 12),
                    ),
                  ]
                : [],
          ),
          child: Stack(
            children: [
              // Top accent line
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: _hovered ? 1 : 0,
                  child: Container(
                    height: 2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.accent, Colors.transparent],
                      ),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
              ),
              // Content
              Row(
                children: [
                  // Icon box
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _hovered
                          ? const Color(0x2D3B82F6)
                          : AppColors.accentDim,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _hovered
                            ? const Color(0x263B82F6)
                            : const Color(0x263B82F6),
                      ),
                      boxShadow: _hovered
                          ? [
                              BoxShadow(
                                color: const Color(0xFF3B82F6).withOpacity(0.2),
                                blurRadius: 16,
                              ),
                            ]
                          : [],
                    ),
                    child: Icon(widget.icon, size: 17, color: AppColors.accent),
                  ),
                  const SizedBox(width: 16),
                  // Text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.card['title']!,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.text,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          widget.card['subtitle']!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.text2,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
