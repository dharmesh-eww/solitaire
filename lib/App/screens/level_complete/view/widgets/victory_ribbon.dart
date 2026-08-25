import 'package:flutter/material.dart';
import '../../../../core/constants/game_colors.dart';

class VictoryRibbon extends StatelessWidget {
  const VictoryRibbon({
    super.key,
    required this.title,
    required this.levelNumber,
  });

  final String title;
  final int levelNumber;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Left ribbon wing
          Positioned(
            left: 8,
            top: 22,
            child: _RibbonWing(isLeft: true),
          ),
          // Right ribbon wing
          Positioned(
            right: 8,
            top: 22,
            child: _RibbonWing(isLeft: false),
          ),
          // Center main banner
          Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFFF5252),
                  Color(0xFFD32F2F),
                  Color(0xFF8E0000),
                ],
                stops: [0.0, 0.45, 1.0],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFFFD54F),
                width: 3.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 14,
                  offset: const Offset(0, 7),
                ),
                BoxShadow(
                  color: const Color(0xFFFFD54F).withValues(alpha: 0.4),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Highlight gloss curve
                Text(
                  title.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFFFF9C4),
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.8,
                    height: 1.1,
                    shadows: [
                      Shadow(
                        color: Color(0xFF4A0000),
                        blurRadius: 4,
                        offset: Offset(0, 3),
                      ),
                      Shadow(
                        color: Color(0xFF200000),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3E0000).withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'LEVEL $levelNumber',
                    style: const TextStyle(
                      color: Color(0xFFFFE082),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Golden crest emblem on top-center
          Positioned(
            top: -6,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFECB3), Color(0xFFFFB300)],
                ),
                border: Border.all(color: Colors.white, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.workspace_premium_rounded,
                size: 16,
                color: Color(0xFF5D4037),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RibbonWing extends StatelessWidget {
  const _RibbonWing({required this.isLeft});

  final bool isLeft;

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scaleX: isLeft ? 1 : -1,
      child: CustomPaint(
        size: const Size(42, 38),
        painter: _RibbonWingPainter(),
      ),
    );
  }
}

class _RibbonWingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFC62828),
          Color(0xFF7F0000),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path()
      ..moveTo(size.width, 0)
      ..lineTo(0, 8)
      ..lineTo(12, size.height / 2 + 4)
      ..lineTo(0, size.height)
      ..lineTo(size.width, size.height - 6)
      ..close();

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawPath(path.shift(const Offset(0, 4)), shadowPaint);
    canvas.drawPath(path, paint);

    final borderPaint = Paint()
      ..color = const Color(0xFFFFD54F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
