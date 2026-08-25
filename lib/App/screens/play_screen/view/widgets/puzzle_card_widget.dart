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
    this.isCompleted = false,
    this.showCrowns = false,
    this.categoryProgress = 0,
    this.categoryRequired = 0,
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
  final bool isCompleted;
  final bool showCrowns;
  final int categoryProgress;
  final int categoryRequired;
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
          duration: const Duration(milliseconds: 160),
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _borderColor(),
              width: _borderWidth(),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: isDragging ? 0.45 : 0.28,
                ),
                blurRadius: isDragging ? 18 : 8,
                offset: Offset(0, isDragging ? 10 : 4),
              ),
              if (isSelected || isHintHighlighted || isActiveCategory)
                BoxShadow(
                  color: GameColors.categoryActiveBorder.withValues(alpha: 0.45),
                  blurRadius: 14,
                  spreadRadius: 1,
                ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(11),
            child: isFaceUp ? _buildFace() : _buildBack(),
          ),
        ),
      ),
    );
  }

  Color _borderColor() {
    if (card == null) {
      if (isActiveCategory || isHintHighlighted) return GameColors.categoryActiveBorder;
      return GameColors.categoryHeader.withValues(alpha: 0.35);
    }
    if (isCompleted) return GameColors.categoryCompletedBorder;
    if (isHintHighlighted || isActiveCategory) return GameColors.categoryActiveBorder;
    if (isSelected) return GameColors.hintBlue;
    if (isCategoryHeader || (card != null && card!.isCategoryHeader)) return GameColors.categoryHeaderDark;
    return GameColors.cardBorder;
  }

  double _borderWidth() {
    if (card == null) return isActiveCategory ? 2.2 : 1.5;
    if (isCompleted) return 2.5;
    if (isSelected || isActiveCategory) return 2.5;
    if (isCategoryHeader || (card != null && card!.isCategoryHeader)) return 1.8;
    return 1.2;
  }

  Widget _buildFace() {
    if (card == null) {
      return _buildEmptySlot();
    }
    if (isCategoryHeader || card!.isCategoryHeader) {
      return _buildCategoryHeaderFace();
    }
    return _buildPlayableFace();
  }

  Widget _buildEmptySlot() {
    return Container(
      decoration: BoxDecoration(
        color: GameColors.headerBar.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.workspace_premium_outlined,
              size: width * 0.32,
              color: GameColors.categoryHeader.withValues(alpha: 0.45),
            ),
            const SizedBox(height: 2),
            Text(
              'CATEGORY',
              style: TextStyle(
                color: GameColors.categoryHeader.withValues(alpha: 0.55),
                fontSize: width * 0.11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryHeaderFace() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isCompleted
              ? [GameColors.categoryCompletedBg, GameColors.categoryHeader]
              : [GameColors.categoryHeader, GameColors.categoryHeaderDark],
        ),
      ),
      child: Stack(
        children: [
          // Total card count for this category — top right
          if (categoryRequired > 0)
            Positioned(
              top: 5,
              right: 6,
              child: Text(
                '$categoryRequired',
                style: TextStyle(
                  color: GameColors.textDark.withValues(alpha: 0.75),
                  fontWeight: FontWeight.w800,
                  fontSize: width * 0.13,
                  height: 1,
                ),
              ),
            ),
          // Crown icons — top left, shown when completed or active
          if (isCompleted)
            Positioned(
              top: 5,
              left: 5,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.workspace_premium_rounded, size: width * 0.18, color: GameColors.crownGold),
                  Icon(Icons.workspace_premium_rounded, size: width * 0.18, color: GameColors.crownGold),
                ],
              ),
            )
          else if (isActiveCategory)
            Positioned(
              top: 5,
              left: 5,
              child: Icon(Icons.workspace_premium_rounded, size: width * 0.18, color: GameColors.crownGold),
            ),
          // Category name — centred
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.08, vertical: 14),
              child: Text(
                card?.content ?? '',
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: GameColors.textDark,
                  fontWeight: FontWeight.w800,
                  fontSize: width * 0.17,
                  height: 1.15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayableFace() {
    return Container(
      color: GameColors.cardFace,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: width * 0.08, vertical: 10),
      child: Text(
        card?.content ?? '',
        textAlign: TextAlign.center,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: GameColors.textDark,
          fontWeight: FontWeight.w700,
          fontSize: width * 0.17,
          height: 1.15,
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
        const Radius.circular(10),
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
        const Radius.circular(9),
      ),
      border,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
