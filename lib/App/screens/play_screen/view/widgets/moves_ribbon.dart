import 'package:flutter/material.dart';
import '../../../../core/constants/game_colors.dart';

class MovesRibbon extends StatelessWidget {
  const MovesRibbon({super.key, required this.moves});

  final int moves;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _RibbonPainter(),
      child: SizedBox(
        width: 90,
        height: 112,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 6),
            const Text(
              'Moves',
              style: TextStyle(
                color: GameColors.textLight,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$moves',
              style: const TextStyle(
                color: GameColors.textLight,
                fontSize: 38,
                fontWeight: FontWeight.w900,
                height: 1,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _RibbonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const radius = 6.0;
    final bodyPath = Path()
      ..moveTo(radius, 0)
      ..lineTo(size.width - radius, 0)
      ..quadraticBezierTo(size.width, 0, size.width, radius)
      ..lineTo(size.width, size.height - 18)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(0, size.height - 18)
      ..lineTo(0, radius)
      ..quadraticBezierTo(0, 0, radius, 0)
      ..close();

    // Shadow
    final shadow = Paint()
      ..color = Colors.black.withValues(alpha: 0.22)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawPath(bodyPath.shift(const Offset(0, 3)), shadow);

    // Main gradient fill
    final gradient = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [GameColors.movesRibbon, GameColors.movesRibbonDark],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(bodyPath, gradient);

    // Highlight line at top
    final highlight = Paint()
      ..color = Colors.white.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final highlightPath = Path()
      ..moveTo(radius + 2, 1)
      ..lineTo(size.width - radius - 2, 1);
    canvas.drawPath(highlightPath, highlight);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
