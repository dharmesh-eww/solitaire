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
        width: 56,
        height: 88,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Moves',
              style: TextStyle(
                color: GameColors.textLight,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '$moves',
              style: const TextStyle(
                color: GameColors.textLight,
                fontSize: 28,
                fontWeight: FontWeight.w800,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RibbonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(4, 0)
      ..lineTo(size.width - 4, 0)
      ..lineTo(size.width, size.height - 14)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(0, size.height - 14)
      ..close();

    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [GameColors.movesRibbon, Color(0xFF1B5E20)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(path, paint);

    final shadow = Paint()
      ..color = Colors.black.withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawPath(path.shift(const Offset(0, 2)), shadow);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
