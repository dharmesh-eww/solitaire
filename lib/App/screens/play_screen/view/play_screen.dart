import 'package:flutter/material.dart';
import 'package:statekit/statekit.dart';

import '../../../core/constants/game_colors.dart';
import '../../../routes/app_routes.dart';
import '../../level_complete/controller/level_complete_controller.dart';
import '../../level_complete/model/level_complete_data.dart';
import '../../level_complete/view/level_complete.dart';
import '../binding/play_screen_binding.dart';
import '../controller/play_screen_controller.dart';
import '../model/card_location.dart';
import 'widgets/game_header.dart';
import 'widgets/game_table_background.dart';
import 'widgets/moves_ribbon.dart';
import 'widgets/puzzle_card_widget.dart';

class PlayScreen extends StatekitView<PlayScreenController> implements PlayScreenBinding {
  PlayScreen({super.key, super.tag});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StateBuilder<PlayScreenController>(
        controller: controller,
        builder: (context, controller, child) {
          return GameTableBackground(
            child: Stack(
              children: [
                SafeArea(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      final columnGap = width < 380 ? 8.0 : 10.0;
                      final horizontalPadding = width < 380 ? 10.0 : 14.0;
                      final cardWidth = (width - horizontalPadding * 2 - columnGap * 3) / 4;
                      final clampedCardWidth = cardWidth.clamp(72.0, 108.0);

                      return Stack(
                        children: [
                          Column(
                            children: [
                              GameHeader(
                                level: controller.level,
                                hintCount: controller.state.hintsRemaining,
                                undoCount: controller.state.undoRemaining,
                                onPause: () => Navigator.maybePop(context),
                                onHint: controller.useHint,
                                onUndo: controller.undo,
                                onMenu: controller.retryLevel,
                              ),
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                                  child: _PlayBoard(
                                    controller: controller,
                                    cardWidth: clampedCardWidth,
                                    columnGap: columnGap,
                                  ),
                                ),
                              ),
                              _InstructionBar(controller: controller),
                              _BottomControls(controller: controller),
                            ],
                          ),
                          // Moves ribbon — top left, overlaid
                          Positioned(left: 0, top: 52, child: MovesRibbon(moves: controller.state.movesRemaining)),
                          if (controller.state.status == GameStatus.outOfMoves) _StatusOverlay(controller: controller),
                        ],
                      );
                    },
                  ),
                ),
                // Animation overlay (above SafeArea so it can go full screen)
                if (controller.animatingCard != null) _AnimationOverlay(controller: controller),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void onLevelCompleted(LevelCompleteData data) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        settings: RouteSettings(name: Routes.levelComplete, arguments: data),
        pageBuilder: (context, animation, secondaryAnimation) => StateProvider(
          stateProvider: StatekitProvider(create: () => LevelCompleteController(data: data)),
          child: LevelComplete(),
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(scale: Tween<double>(begin: 0.88, end: 1.0).animate(curved), child: child),
          );
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Play Board
// ─────────────────────────────────────────────────────────────

class _PlayBoard extends StatelessWidget {
  const _PlayBoard({required this.controller, required this.cardWidth, required this.columnGap});

  final PlayScreenController controller;
  final double cardWidth;
  final double columnGap;

  @override
  Widget build(BuildContext context) {
    final cardHeight = cardWidth * 1.38;
    return Column(
      children: [
        // Waste + Stock row
        SizedBox(
          height: cardHeight + 8,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Spacer left for the moves ribbon
              const SizedBox(width: 96),
              // Waste fan — takes remaining space
              Expanded(
                child: _WasteFan(controller: controller, cardWidth: cardWidth),
              ),
              const SizedBox(width: 10),
              // Stock pile — top right
              _StockPile(controller: controller, cardWidth: cardWidth),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Category columns + stacked cards
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < controller.state.columns.length; i++) ...[
                Expanded(
                  child: CategoryColumn(controller: controller, columnIndex: i, cardWidth: cardWidth),
                ),
                if (i != controller.state.columns.length - 1) SizedBox(width: columnGap),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Category Column
// ─────────────────────────────────────────────────────────────

class CategoryColumn extends StatelessWidget {
  const CategoryColumn({super.key, required this.controller, required this.columnIndex, required this.cardWidth});

  final PlayScreenController controller;
  final int columnIndex;
  final double cardWidth;

  @override
  Widget build(BuildContext context) {
    final columnKey = controller.columnKeys.putIfAbsent(columnIndex, () => GlobalKey());
    final state = controller.state;
    final category = state.puzzle.categories[columnIndex];
    final column = state.columns[columnIndex];
    final cardHeight = cardWidth * 1.38;
    final stackStep = cardHeight * 0.22;

    final isCompleted = state.completedCategories.contains(category.id);
    final isActive = state.activeCategoryId == category.id || state.hintCategoryId == category.id;

    return DragTarget<String>(
      key: columnKey,
      onWillAcceptWithDetails: (details) => controller.canDropOnColumn(details.data, columnIndex),
      onAcceptWithDetails: (details) => controller.onCardDropped(details.data, columnIndex, details.offset),
      builder: (context, candidateData, rejectedData) {
        return GestureDetector(
          onTap: () => controller.tapCategory(columnIndex),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOut,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ── Category header card — fixed cardWidth × cardHeight ──
                SizedBox(
                  width: cardWidth,
                  height: cardHeight,
                  child: PuzzleCardWidget(
                    card: column.isNotEmpty ? state.puzzle.cardById(column[0]) : null,
                    width: cardWidth,
                    isFaceUp: true,
                    isCategoryHeader: true,
                    isActiveCategory: isActive,
                    isCompleted: isCompleted,
                    categoryProgress: state.categoryProgress[category.id] ?? 0,
                    categoryRequired: category.requiredItemCount,
                  ),
                ),
                const SizedBox(height: 12),
                // ── Stacked playable cards — same width, overlapping stack ──
                if (column.length > 1)
                  SizedBox(
                    width: cardWidth,
                    height: cardHeight + stackStep * (column.length - 2),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        for (var i = 1; i < column.length; i++)
                          AnimatedPositioned(
                            key: ValueKey(column[i]),
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOutCubic,
                            top: (i - 1) * stackStep,
                            left: 0,
                            right: 0,
                            child: SizedBox(
                              width: cardWidth,
                              height: cardHeight,
                              child: _PlayableCard(
                                controller: controller,
                                cardId: column[i],
                                cardWidth: cardWidth,
                                isTopCard: i == column.length - 1,
                              ),
                            ),
                          ),
                        // No drop indicator shown during drag
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Drop Indicator
// ─────────────────────────────────────────────────────────────

class DropIndicator extends StatelessWidget {
  const DropIndicator({super.key, required this.cardWidth});

  final double cardWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: cardWidth,
      height: cardWidth * 1.38,
      decoration: BoxDecoration(
        color: GameColors.dropValid.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: GameColors.dropValid.withValues(alpha: 0.65), width: 1.8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.arrow_downward_rounded, color: GameColors.dropValid, size: 18),
          const SizedBox(height: 2),
          Text(
            'DROP',
            style: TextStyle(color: GameColors.dropValid, fontWeight: FontWeight.w900, fontSize: cardWidth * 0.12),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Playable Card (with drag support)
// ─────────────────────────────────────────────────────────────

class _PlayableCard extends StatelessWidget {
  const _PlayableCard({
    required this.controller,
    required this.cardId,
    required this.cardWidth,
    required this.isTopCard,
  });

  final PlayScreenController controller;
  final String cardId;
  final double cardWidth;
  final bool isTopCard;

  @override
  Widget build(BuildContext context) {
    final cardKey = controller.cardKeys.putIfAbsent(cardId, () => GlobalKey());
    final card = controller.state.puzzle.cardById(cardId);
    final faceUp = controller.isFaceUp(cardId);
    final playable = isTopCard && controller.isPlayable(cardId);
    final isHidden = controller.hiddenCardId == cardId;

    final child = Opacity(
      opacity: isHidden ? 0.0 : 1.0,
      child: PuzzleCardWidget(
        card: card,
        width: cardWidth,
        isFaceUp: faceUp,
        isSelected: controller.state.selectedCardId == cardId && !isHidden,
        isHintHighlighted: controller.state.hintCardId == cardId,
        onTap: playable && !isHidden ? () => controller.selectCard(cardId) : null,
      ),
    );

    if (!playable || isHidden) {
      return SizedBox(
        key: cardKey,
        child: IgnorePointer(child: child),
      );
    }

    return SizedBox(
      key: cardKey,
      child: Draggable<String>(
        data: cardId,
        dragAnchorStrategy: pointerDragAnchorStrategy,
        feedback: Material(
          color: Colors.transparent,
          child: Transform.rotate(
            angle: 0.04,
            child: PuzzleCardWidget(card: card, width: cardWidth, isFaceUp: true, isDragging: true),
          ),
        ),
        childWhenDragging: Opacity(opacity: 0.0, child: child),
        onDragStarted: () => controller.onDragStart(cardId),
        onDragEnd: (_) {
          // Cleanup handled in onCardDropped or onDragCanceled
        },
        onDraggableCanceled: (velocity, offset) => controller.onDragCanceled(cardId, offset),
        child: child,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Waste Fan
// ─────────────────────────────────────────────────────────────

class _WasteFan extends StatelessWidget {
  const _WasteFan({required this.controller, required this.cardWidth});

  final PlayScreenController controller;
  final double cardWidth;

  @override
  Widget build(BuildContext context) {
    final waste = controller.state.waste;
    if (waste.isEmpty) return const SizedBox.shrink();
    final visible = waste.length <= 3 ? waste : waste.sublist(waste.length - 3);

    return SizedBox(
      height: cardWidth * 1.38,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (var i = 0; i < visible.length; i++)
            Positioned(
              left: i * cardWidth * 0.28,
              bottom: 0,
              child: Opacity(
                opacity: i == visible.length - 1 ? 1.0 : 0.9,
                child: _PlayableCard(
                  controller: controller,
                  cardId: visible[i],
                  cardWidth: cardWidth,
                  isTopCard: i == visible.length - 1,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Stock Pile
// ─────────────────────────────────────────────────────────────

class _StockPile extends StatelessWidget {
  const _StockPile({required this.controller, required this.cardWidth});

  final PlayScreenController controller;
  final double cardWidth;

  @override
  Widget build(BuildContext context) {
    final count = controller.state.stock.length;
    return GestureDetector(
      onTap: count > 0 ? controller.drawFromStock : null,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Stack depth illusion
          for (var i = 2; i >= 0; i--)
            Transform.translate(
              offset: Offset(0, i * 2.0),
              child: Opacity(
                opacity: count > i ? 1.0 : 0.2,
                child: PuzzleCardWidget(card: null, width: cardWidth, isFaceUp: false),
              ),
            ),
          if (count > 0)
            Positioned(
              top: 5,
              right: 5,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 4)],
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    color: GameColors.textDark,
                    fontWeight: FontWeight.w900,
                    fontSize: cardWidth * 0.145,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Instruction Bar (arrow-banner style)
// ─────────────────────────────────────────────────────────────

class _InstructionBar extends StatelessWidget {
  const _InstructionBar({required this.controller});

  final PlayScreenController controller;

  @override
  Widget build(BuildContext context) {
    final activeId = controller.state.activeCategoryId;
    final hintId = controller.state.hintCategoryId;
    final showId = hintId ?? activeId;
    final category = showId == null ? null : controller.state.puzzle.categoryById(showId);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: ClipPath(
        clipper: _ArrowBannerClipper(),
        child: Container(
          padding: const EdgeInsets.only(left: 14, right: 28, top: 10, bottom: 10),
          color: GameColors.instructionBar,
          child: Row(
            children: [
              // Green info circle
              Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(color: Color(0xFF2E7D32), shape: BoxShape.circle),
                child: const Icon(Icons.info_rounded, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Find all cards that belong to\n',
                        style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      TextSpan(
                        text: category?.name ?? 'the categories',
                        style: const TextStyle(
                          color: GameColors.categoryHeader,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      if (category != null)
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Icon(Icons.workspace_premium_rounded, color: GameColors.crownGold, size: 16),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ArrowBannerClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const arrowWidth = 16.0;
    const radius = 10.0;
    final path = Path()
      ..moveTo(radius, 0)
      ..lineTo(size.width - arrowWidth - radius, 0)
      ..quadraticBezierTo(size.width - arrowWidth, 0, size.width - arrowWidth + arrowWidth * 0.5, size.height / 2)
      ..lineTo(size.width - arrowWidth + arrowWidth * 0.5, size.height / 2)
      ..lineTo(size.width - arrowWidth, size.height)
      ..lineTo(radius, size.height)
      ..quadraticBezierTo(0, size.height, 0, size.height - radius)
      ..lineTo(0, radius)
      ..quadraticBezierTo(0, 0, radius, 0)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// ─────────────────────────────────────────────────────────────
// Bottom Controls (Hint / Undo / Shuffle)
// ─────────────────────────────────────────────────────────────

class _BottomControls extends StatelessWidget {
  const _BottomControls({required this.controller});

  final PlayScreenController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      child: Row(
        children: [
          Expanded(
            child: _ActionButton(
              label: 'Hint',
              icon: Icons.lightbulb_rounded,
              topColor: GameColors.hintBlue,
              bottomColor: GameColors.hintBlueDark,
              badge: controller.state.hintsRemaining,
              badgeIsCoin: true,
              onTap: controller.useHint,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _ActionButton(
              label: 'Undo',
              icon: Icons.undo_rounded,
              topColor: GameColors.undoGrey,
              bottomColor: GameColors.undoGreyDark,
              badge: controller.state.undoRemaining,
              badgeIsCoin: false,
              onTap: controller.undo,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _ActionButton(
              label: 'Shuffle',
              icon: Icons.shuffle_rounded,
              topColor: GameColors.shuffleOrange,
              bottomColor: GameColors.shuffleOrangeDark,
              badge: controller.state.shufflesRemaining,
              badgeIsCoin: false,
              hasBadgePlay: true,
              onTap: controller.shuffle,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.topColor,
    required this.bottomColor,
    required this.badge,
    required this.badgeIsCoin,
    required this.onTap,
    this.hasBadgePlay = false,
  });

  final String label;
  final IconData icon;
  final Color topColor;
  final Color bottomColor;
  final int badge;
  final bool badgeIsCoin;
  final bool hasBadgePlay;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Button shadow (offset bottom layer)
          Positioned(
            bottom: -3,
            left: 2,
            right: 2,
            child: Container(
              height: 58,
              decoration: BoxDecoration(color: bottomColor, borderRadius: BorderRadius.circular(18)),
            ),
          ),
          // Main button
          Container(
            height: 58,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [topColor, bottomColor],
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.22), width: 1.2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 22),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          // Badge (red count or coin badge) — only shown when hasBadgePlay is false
          if (badge > 0 && !hasBadgePlay)
            Positioned(
              right: -4,
              top: -6,
              child: badgeIsCoin ? _CoinCountBadge(count: badge) : _RedCountBadge(count: badge),
            ),
          // Play badge for shuffle — replaces the red count badge
          if (hasBadgePlay && badge > 0)
            Positioned(
              right: -4,
              top: -6,
              child: Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: const Icon(Icons.play_arrow_rounded, color: GameColors.shuffleOrange, size: 17),
              ),
            ),
        ],
      ),
    );
  }
}

class _RedCountBadge extends StatelessWidget {
  const _RedCountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: GameColors.badgeRed,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Text(
        '$count',
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11),
      ),
    );
  }
}

class _CoinCountBadge extends StatelessWidget {
  const _CoinCountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: GameColors.coinGold,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.workspace_premium_rounded, color: Color(0xFFBF7D00), size: 11),
          const SizedBox(width: 2),
          Text(
            '$count',
            style: const TextStyle(color: Color(0xFF5C3A00), fontWeight: FontWeight.w900, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Status Overlay (Win / Out of Moves)
// ─────────────────────────────────────────────────────────────

class _StatusOverlay extends StatelessWidget {
  const _StatusOverlay({required this.controller});

  final PlayScreenController controller;

  @override
  Widget build(BuildContext context) {
    final won = controller.state.status == GameStatus.won;
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.5),
        alignment: Alignment.center,
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: GameColors.cardFace,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.45), blurRadius: 28, offset: const Offset(0, 12)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: won
                      ? GameColors.coinGold.withValues(alpha: 0.15)
                      : GameColors.badgeRed.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  won ? Icons.emoji_events_rounded : Icons.timer_off_rounded,
                  color: won ? GameColors.crownGold : GameColors.badgeRed,
                  size: 42,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                won ? 'Level Complete!' : 'Out of Moves',
                style: TextStyle(
                  color: won ? GameColors.crownGold : GameColors.badgeRed,
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                won
                    ? 'Level ${controller.level} cleared with ${controller.state.movesRemaining} moves left!'
                    : 'Undo a move or retry this puzzle.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: GameColors.textMid, fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _DialogButton(
                      label: 'Retry',
                      onTap: controller.retryLevel,
                      topColor: GameColors.undoGrey,
                      bottomColor: GameColors.undoGreyDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DialogButton(
                      label: won ? 'Next ▶' : 'Undo',
                      onTap: won ? controller.retryLevel : controller.undo,
                      topColor: GameColors.shuffleOrange,
                      bottomColor: GameColors.shuffleOrangeDark,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DialogButton extends StatelessWidget {
  const _DialogButton({required this.label, required this.onTap, required this.topColor, required this.bottomColor});

  final String label;
  final VoidCallback onTap;
  final Color topColor;
  final Color bottomColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [topColor, bottomColor],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: bottomColor.withValues(alpha: 0.55), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Text(
          label,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Animation Overlay
// ─────────────────────────────────────────────────────────────

class _AnimationOverlay extends StatelessWidget {
  const _AnimationOverlay({required this.controller});

  final PlayScreenController controller;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columnGap = width < 380 ? 8.0 : 10.0;
        final horizontalPadding = width < 380 ? 10.0 : 14.0;
        final cardWidth = (width - horizontalPadding * 2 - columnGap * 3) / 4;
        final clampedCardWidth = cardWidth.clamp(72.0, 108.0);

        return Stack(
          children: [
            CardAnimationWidget(state: controller.animatingCard!, cardWidth: clampedCardWidth, controller: controller),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Card Animation Widget
// ─────────────────────────────────────────────────────────────

class CardAnimationWidget extends StatefulWidget {
  final AnimatingCardState state;
  final double cardWidth;
  final PlayScreenController controller;

  const CardAnimationWidget({super.key, required this.state, required this.cardWidth, required this.controller});

  @override
  State<CardAnimationWidget> createState() => _CardAnimationWidgetState();
}

class _CardAnimationWidgetState extends State<CardAnimationWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _positionAnimation;
  late Animation<double> _shakeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 240), vsync: this);

    _positionAnimation = Tween<Offset>(
      begin: widget.state.startOffset,
      end: widget.state.endOffset,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _scaleAnimation = Tween<double>(
      begin: widget.state.isShake ? 1.06 : 1.03,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _rotationAnimation = Tween<double>(
      begin: widget.state.isShake ? 0.04 : 0.02,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    if (widget.state.isShake) {
      _shakeAnimation =
          TweenSequence<double>([
            TweenSequenceItem(tween: Tween(begin: 0.0, end: 10.0), weight: 1),
            TweenSequenceItem(tween: Tween(begin: 10.0, end: -10.0), weight: 2),
            TweenSequenceItem(tween: Tween(begin: -10.0, end: 6.0), weight: 2),
            TweenSequenceItem(tween: Tween(begin: 6.0, end: -6.0), weight: 2),
            TweenSequenceItem(tween: Tween(begin: -6.0, end: 0.0), weight: 1),
          ]).animate(
            CurvedAnimation(
              parent: _controller,
              curve: const Interval(0.0, 0.5, curve: Curves.linear),
            ),
          );
    } else {
      _shakeAnimation = const AlwaysStoppedAnimation(0.0);
    }

    _controller.forward().then((_) {
      widget.state.onComplete();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final card = widget.controller.state.puzzle.cardById(widget.state.cardId);
    if (card == null) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final position = _positionAnimation.value;
        final shake = _shakeAnimation.value;
        final scale = _scaleAnimation.value;
        final rotation = _rotationAnimation.value;

        return Positioned(
          left: position.dx + shake,
          top: position.dy,
          child: IgnorePointer(
            child: Transform.rotate(
              angle: rotation,
              child: Transform.scale(
                scale: scale,
                child: Material(
                  color: Colors.transparent,
                  child: PuzzleCardWidget(
                    card: card,
                    width: widget.cardWidth,
                    isFaceUp: true,
                    isDragging: scale > 1.01,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
