import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/constants/game_colors.dart';

class ConfettiParticles extends StatefulWidget {
  const ConfettiParticles({super.key});

  @override
  State<ConfettiParticles> createState() => _ConfettiParticlesState();
}

class _ConfettiParticlesState extends State<ConfettiParticles>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<_Particle> _particles = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _initParticles();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  void _initParticles() {
    const colors = [
      GameColors.coinGold,
      GameColors.crownGold,
      Color(0xFFFF5252),
      Color(0xFF448AFF),
      Color(0xFF69F0AE),
      Color(0xFFFFD740),
      Color(0xFFE040FB),
      Colors.white,
    ];

    for (var i = 0; i < 45; i++) {
      _particles.add(
        _Particle(
          x: _random.nextDouble(),
          y: _random.nextDouble(),
          size: _random.nextDouble() * 8 + 4,
          speedY: _random.nextDouble() * 0.15 + 0.08,
          speedX: (_random.nextDouble() - 0.5) * 0.08,
          rotation: _random.nextDouble() * 2 * math.pi,
          rotationSpeed: (_random.nextDouble() - 0.5) * 4,
          color: colors[_random.nextInt(colors.length)],
          isStar: i % 4 == 0,
        ),
      );
    }
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
        return CustomPaint(
          size: Size.infinite,
          painter: _ConfettiPainter(
            particles: _particles,
            progress: _controller.value,
          ),
        );
      },
    );
  }
}

class _Particle {
  _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speedY,
    required this.speedX,
    required this.rotation,
    required this.rotationSpeed,
    required this.color,
    required this.isStar,
  });

  double x;
  double y;
  double size;
  double speedY;
  double speedX;
  double rotation;
  double rotationSpeed;
  Color color;
  bool isStar;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.particles, required this.progress});

  final List<_Particle> particles;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final p in particles) {
      final curY = ((p.y + progress * p.speedY * 2.5) % 1.0) * size.height;
      final curX = ((p.x + progress * p.speedX + math.sin(progress * 4 + p.y * 10) * 0.02) % 1.0) * size.width;
      final curRot = p.rotation + progress * p.rotationSpeed * 2 * math.pi;

      canvas.save();
      canvas.translate(curX, curY);
      canvas.rotate(curRot);

      paint.color = p.color.withValues(alpha: 0.85);

      if (p.isStar) {
        // Draw 4-point sparkle star
        final path = Path()
          ..moveTo(0, -p.size)
          ..quadraticBezierTo(0, 0, p.size, 0)
          ..quadraticBezierTo(0, 0, 0, p.size)
          ..quadraticBezierTo(0, 0, -p.size, 0)
          ..quadraticBezierTo(0, 0, 0, -p.size)
          ..close();
        canvas.drawPath(path, paint);
      } else {
        // Fluttering confetti rectangle
        final scaleX = math.cos(curRot * 2);
        canvas.scale(scaleX.abs().clamp(0.2, 1.0), 1.0);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.6),
            const Radius.circular(2),
          ),
          paint,
        );
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}
