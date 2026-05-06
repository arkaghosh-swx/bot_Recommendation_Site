// lib/shared/widgets/app_background.dart

import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class AppBackground extends StatefulWidget {
  final Widget child;
  const AppBackground({super.key, required this.child});

  @override
  State<AppBackground> createState() => _AppBackgroundState();
}

class _AppBackgroundState extends State<AppBackground>
    with TickerProviderStateMixin {
  late final AnimationController _ctrl1;
  late final AnimationController _ctrl2;

  @override
  void initState() {
    super.initState();
    _ctrl1 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 22),
    )..repeat(reverse: true);
    _ctrl2 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 28),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl1.dispose();
    _ctrl2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Grid
        Positioned.fill(child: CustomPaint(painter: _BgGridPainter())),

        // Glow 1 — top left (accent green)
        AnimatedBuilder(
          animation: _ctrl1,
          builder: (_, _) => Positioned(
            top: -200 + 70 * _ctrl1.value,
            left: -200 + 80 * _ctrl1.value,
            child: _Glow(size: 700, color: AppColors.accent, opacity: 0.18),
          ),
        ),

        // Glow 2 — bottom right (wa green)
        AnimatedBuilder(
          animation: _ctrl2,
          builder: (_, _) => Positioned(
            bottom: -150 + 80 * _ctrl2.value,
            right: -150 + 60 * _ctrl2.value,
            child: _Glow(size: 600, color: AppColors.accentWa, opacity: 0.13),
          ),
        ),

        // Main content
        widget.child,
      ],
    );
  }
}

class _Glow extends StatelessWidget {
  final double size;
  final Color color;
  final double opacity;

  const _Glow({required this.size, required this.color, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color.withOpacity(opacity), Colors.transparent],
            stops: const [0.0, 0.7],
          ),
        ),
      ),
    );
  }
}

class _BgGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final hPaint = Paint()
      ..color = const Color(0xFF8FB3A5).withOpacity(0.05)
      ..strokeWidth = 1;
    final vPaint = Paint()
      ..color = const Color(0xFF3B82F6).withOpacity(0.03)
      ..strokeWidth = 1;

    const step = 52.0;
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), hPaint);
    }
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), vPaint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
