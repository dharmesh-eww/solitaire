import 'package:flutter/material.dart';
import '../../../../core/puzzle/puzzle_card.dart';
import '../../../../core/constants/game_colors.dart';

class PuzzleCardWidget extends StatelessWidget {
  const PuzzleCardWidget({
    super.key,
    required this.card,
    required this.width,
    this.isFaceUp = true,
    this.isSelected = false,
    this.isHintHighlighted = false,
    this.isDragging = false,
    this.isCategoryHeader = false,
    this.isActiveCategory = false,
    this.showCrowns = false,
    this.onTap,
  });

  final PuzzleCard? card;
  final double width;
  final bool isFaceUp;
  final bool isSelected;
  final bool isHintHighlighted;
  final bool isDragging;
  final bool isCategoryHeader;
  final bool isActiveCategory;
  final bool showCrowns;
  final VoidCallback? onTap;

  double get height => width * 1.38;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: isDragging ? 1.06 : isSelected ? 1.03 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _borderColor(),
              width: isSelected || isActiveCategory ? 2.5 : 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: isDragging ? 0.45 : 0.28,
                ),
                blurRadius: isDragging ? 16 : 8,
                offset: Offset(0, isDragging ? 10 : 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(9),
            child: isFaceUp ? _buildFace() : _buildBack(),
          ),
        ),
      ),
    );
  }

  Color _borderColor() {
    if (isHintHighlighted || isActiveCategory) {
      return GameColors.categoryActiveBorder;
    }
    if (isSelected) return GameColors.hintBlue;
    return GameColors.cardBorder;
  }

  Widget _buildFace() {
    if (isCategoryHeader) {
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              GameColors.categoryHeader,
              GameColors.categoryHeaderDark,
            ],
          ),
        ),
        child: Stack(
          children: [
            if (showCrowns)
              Positioned(
                top: 6,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    2,
                    (_) => Icon(
                      Icons.workspace_premium_rounded,
                      size: width * 0.18,
                      color: GameColors.crownGold,
                    ),
                  ),
                ),
              ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  card?.content ?? '',
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: GameColors.textDark,
                    fontWeight: FontWeight.w800,
                    fontSize: width * 0.16,
                    height: 1.1,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      color: GameColors.cardFace,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: Text(
        card?.content ?? '',
        textAlign: TextAlign.center,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: GameColors.textDark,
          fontWeight: FontWeight.w700,
          fontSize: width * 0.17,
          height: 1.1,
        ),
      ),
    );
  }

  Widget _buildBack() {
    return CustomPaint(
      painter: _CardBackPainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _CardBackPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = GameColors.cardBack;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(8),
      ),
      bg,
    );

    final patternPaint = Paint()
      ..color = GameColors.cardBackPattern.withValues(alpha: 0.55)
      ..style = PaintingStyle.fill;

    const diamond = 10.0;
    for (var y = -diamond; y < size.height + diamond; y += diamond * 2) {
      for (var x = -diamond; x < size.width + diamond; x += diamond * 2) {
        final offsetX = (y ~/ (diamond * 2)) % 2 == 0 ? 0.0 : diamond;
        final path = Path()
          ..moveTo(x + offsetX, y)
          ..lineTo(x + offsetX + diamond, y + diamond)
          ..lineTo(x + offsetX, y + diamond * 2)
          ..lineTo(x + offsetX - diamond, y + diamond)
          ..close();
        canvas.drawPath(path, patternPaint);
      }
    }

    final border = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(1, 1, size.width - 2, size.height - 2),
        const Radius.circular(7),
      ),
      border,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
