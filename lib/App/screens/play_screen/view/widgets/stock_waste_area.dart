import 'package:flutter/material.dart';
import '../../../../core/constants/game_colors.dart';
import '../../../../core/puzzle/puzzle_card.dart';
import 'puzzle_card_widget.dart';

class StockWasteArea extends StatelessWidget {
  const StockWasteArea({
    super.key,
    required this.cardWidth,
    required this.wasteCardIds,
    required this.stockCount,
    required this.cardById,
    required this.isFaceUp,
    required this.selectedCardId,
    required this.hintCardId,
    required this.onWasteCardTap,
    required this.onStockTap,
  });

  final double cardWidth;
  final List<String> wasteCardIds;
  final int stockCount;
  final PuzzleCard? Function(String id) cardById;
  final bool Function(String id) isFaceUp;
  final String? selectedCardId;
  final String? hintCardId;
  final ValueChanged<String> onWasteCardTap;
  final VoidCallback onStockTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: cardWidth * 1.38 + 8,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: _WasteFan(
              cardWidth: cardWidth,
              wasteCardIds: wasteCardIds,
              cardById: cardById,
              isFaceUp: isFaceUp,
              selectedCardId: selectedCardId,
              hintCardId: hintCardId,
              onWasteCardTap: onWasteCardTap,
            ),
          ),
          const SizedBox(width: 8),
          _StockPile(
            cardWidth: cardWidth,
            stockCount: stockCount,
            onStockTap: onStockTap,
          ),
        ],
      ),
    );
  }
}

class _WasteFan extends StatelessWidget {
  const _WasteFan({
    required this.cardWidth,
    required this.wasteCardIds,
    required this.cardById,
    required this.isFaceUp,
    required this.selectedCardId,
    required this.hintCardId,
    required this.onWasteCardTap,
  });

  final double cardWidth;
  final List<String> wasteCardIds;
  final PuzzleCard? Function(String id) cardById;
  final bool Function(String id) isFaceUp;
  final String? selectedCardId;
  final String? hintCardId;
  final ValueChanged<String> onWasteCardTap;

  @override
  Widget build(BuildContext context) {
    if (wasteCardIds.isEmpty) {
      return const SizedBox.shrink();
    }

    final visible = wasteCardIds.length <= 3
        ? wasteCardIds
        : wasteCardIds.sublist(wasteCardIds.length - 3);

    return SizedBox(
      height: cardWidth * 1.38,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (var i = 0; i < visible.length; i++)
            Positioned(
              left: i * (cardWidth * 0.28),
              bottom: 0,
              child: Opacity(
                opacity: i == visible.length - 1 ? 1.0 : 0.92,
                child: PuzzleCardWidget(
                  card: cardById(visible[i]),
                  width: cardWidth,
                  isFaceUp: isFaceUp(visible[i]),
                  isSelected: selectedCardId == visible[i],
                  isHintHighlighted: hintCardId == visible[i],
                  onTap: () => onWasteCardTap(visible[i]),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StockPile extends StatelessWidget {
  const _StockPile({
    required this.cardWidth,
    required this.stockCount,
    required this.onStockTap,
  });

  final double cardWidth;
  final int stockCount;
  final VoidCallback onStockTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: stockCount > 0 ? onStockTap : null,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (stockCount > 0) ...[
            Transform.translate(
              offset: const Offset(0, 4),
              child: Opacity(
                opacity: 0.5,
                child: PuzzleCardWidget(
                  card: null,
                  width: cardWidth,
                  isFaceUp: false,
                ),
              ),
            ),
            Transform.translate(
              offset: const Offset(0, 2),
              child: Opacity(
                opacity: 0.75,
                child: PuzzleCardWidget(
                  card: null,
                  width: cardWidth,
                  isFaceUp: false,
                ),
              ),
            ),
          ],
          PuzzleCardWidget(card: null, width: cardWidth, isFaceUp: false),
          if (stockCount > 0)
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$stockCount',
                  style: TextStyle(
                    color: GameColors.textDark,
                    fontWeight: FontWeight.w800,
                    fontSize: cardWidth * 0.14,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
