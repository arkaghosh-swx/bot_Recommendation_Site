// lib/features/home/widgets/hero_section.dart

// import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        isMobile ? 18 : 48,
        isMobile ? 26 : 56,
        isMobile ? 18 : 48,
        isMobile ? 22 : 44,
      ),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Stack(
        children: [
          // Background grid
          const _HeroBgGrid(),

          // Orb 1
          Positioned(
            top: -100,
            right: -80,
            child: _Orb(size: 300, color: AppColors.orbBlue, opacity: 0.10),
          ),

          // Orb 2
          Positioned(
            bottom: -80,
            left: 80,
            child: _Orb(size: 220, color: AppColors.orbGreen, opacity: 0.08),
          ),

          // Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pill
              _HeroPill().animate().fadeIn(delay: 0.ms).slideY(begin: 0.3),
              const SizedBox(height: 22),

              // Heading
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontFamily: 'Syne',
                    fontWeight: FontWeight.w800,
                    fontSize: isMobile ? 28 : 48,
                    letterSpacing: -1.5,
                    height: 1.08,
                    color: AppColors.text,
                  ),
                  children: const [
                    TextSpan(text: 'Understand your\n'),
                    TextSpan(
                      text: 'health',
                      style: TextStyle(color: AppColors.accent),
                    ),
                    TextSpan(text: ' better.'),
                  ],
                ),
              ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.3),
              const SizedBox(height: 16),

              // Sub
              Text(
                'Ask about treatments, consultations, and how homoeopathy can help you.',
                style: TextStyle(
                  fontSize: isMobile ? 14 : 15.5,
                  color: AppColors.text2,
                  fontWeight: FontWeight.w300,
                  height: 1.75,
                ),
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3),
              const SizedBox(height: 32),

              // Stats strip
              _StatsStrip(
                isMobile: isMobile,
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.3),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Pill ───────────────────────────────────────────────────
class _HeroPill extends StatefulWidget {
  @override
  State<_HeroPill> createState() => _HeroPillState();
}

class _HeroPillState extends State<_HeroPill>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.accentDim,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0x383B82F6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _ctrl,
            builder: (_, _) => Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.4 + 0.6 * _ctrl.value),
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'AI-Powered Health Assistant',
            style: TextStyle(
              fontFamily: 'Syne',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.accent,
              letterSpacing: 0.04 * 12,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stats Strip ────────────────────────────────────────────
class _StatsStrip extends StatelessWidget {
  final bool isMobile;
  const _StatsStrip({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 14 : 28,
        vertical: isMobile ? 14 : 18,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withOpacity(0.08),
            spreadRadius: 1,
            blurRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 24,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: AppConstants.stats.map((s) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: _Stat(value: s['value']!, label: s['label']!),
                );
              }).toList(),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int i = 0; i < AppConstants.stats.length; i++) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: _Stat(
                      value: AppConstants.stats[i]['value']!,
                      label: AppConstants.stats[i]['label']!,
                    ),
                  ),
                  if (i < AppConstants.stats.length - 1)
                    Container(width: 1, height: 40, color: AppColors.border2),
                ],
              ],
            ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  const _Stat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Syne',
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: AppColors.accent,
            letterSpacing: -1,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 11.5, color: AppColors.text2),
        ),
      ],
    );
  }
}

// ── Background grid ────────────────────────────────────────
class _HeroBgGrid extends StatelessWidget {
  const _HeroBgGrid();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(child: CustomPaint(painter: _GridPainter()));
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF3B82F6).withOpacity(0.04)
      ..strokeWidth = 1;

    const step = 48.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Orb ───────────────────────────────────────────────────
class _Orb extends StatelessWidget {
  final double size;
  final Color color;
  final double opacity;

  const _Orb({required this.size, required this.color, required this.opacity});

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
          ),
        ),
      ),
    );
  }
}
