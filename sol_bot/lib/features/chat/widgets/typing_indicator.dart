// lib/features/chat/widgets/typing_indicator.dart

import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      3,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      )..repeat(reverse: true, period: Duration(milliseconds: 1400 + i * 200)),
    );

    _animations = _controllers
        .asMap()
        .entries
        .map((e) => CurvedAnimation(parent: e.value, curve: Curves.easeInOut))
        .toList();

    // Stagger the starts
    for (int i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) _controllers[i].repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Bot avatar
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: AppColors.botAvatarGrad,
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Center(
              child: Text(
                'AI',
                style: TextStyle(
                  fontFamily: 'Syne',
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Typing bubble
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surface2,
              border: Border.all(color: AppColors.border),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(18),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                return AnimatedBuilder(
                  animation: _animations[i],
                  builder: (_, _) => Container(
                    margin: EdgeInsets.only(right: i < 2 ? 5 : 0),
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(
                        0.4 + 0.6 * _animations[i].value,
                      ),
                      shape: BoxShape.circle,
                    ),
                    transform: Matrix4.translationValues(
                      0,
                      -7 * _animations[i].value,
                      0,
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
