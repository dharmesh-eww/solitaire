import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/constants/game_colors.dart';

class SunburstRays extends StatefulWidget {
  const SunburstRays({super.key, this.size = 500});

  final double size;

  @override
  State<SunburstRays> createState() => _SunburstRaysState();
}

class _SunburstRaysState extends State<SunburstRays>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _controller.value * 2 * math.pi,
          child: CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _SunburstPainter(),
          ),
        );
      },
    );
  }
}

class _SunburstPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const rayCount = 16;
    const angleStep = (2 * math.pi) / rayCount;

    final rayPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          GameColors.coinGold.withValues(alpha: 0.28),
          GameColors.categoryHeader.withValues(alpha: 0.14),
          Colors.transparent,
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    for (var i = 0; i < rayCount; i += 2) {
      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..arcTo(
          Rect.fromCircle(center: center, radius: radius),
          i * angleStep,
          angleStep * 0.82,
          false,
        )
        ..close();
      canvas.drawPath(path, rayPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
