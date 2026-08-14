import 'package:flutter/material.dart';
import 'package:statekit/statekit.dart';

import '../../../core/constants/game_colors.dart';
import '../binding/play_screen_binding.dart';
import '../controller/play_screen_controller.dart';
import '../model/card_location.dart';
import 'widgets/game_header.dart';
import 'widgets/game_table_background.dart';
import 'widgets/moves_ribbon.dart';
import 'widgets/puzzle_card_widget.dart';

// ignore: must_be_immutable
class PlayScreen extends StatekitView<PlayScreenController>
    implements PlayScreenBinding {
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
                      final columnGap = width < 380 ? 8.0 : 12.0;
                      final horizontalPadding = width < 380 ? 12.0 : 18.0;
                      final cardWidth =
                          (width - horizontalPadding * 2 - columnGap * 3) / 4;
                      final clampedCardWidth = cardWidth.clamp(72.0, 104.0);

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
                                  padding: EdgeInsets.symmetric(
                                    horizontal: horizontalPadding,
                                  ),
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
                          Positioned(
                            left: 12,
                            top: 92,
                            child: MovesRibbon(
                              moves: controller.state.movesRemaining,
                            ),
                          ),
                          if (controller.state.status != GameStatus.playing)
                            _StatusOverlay(controller: controller),
                        ],
                      );
                    },
                  ),
                ),
                if (controller.animatingCard != null)
                  _AnimationOverlay(controller: controller),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void doSomething() {}
}

class _PlayBoard extends StatelessWidget {
  const _PlayBoard({
    required this.controller,
    required this.cardWidth,
    required this.columnGap,
  });

  final PlayScreenController controller;
  final double cardWidth;
  final double columnGap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: cardWidth * 1.45,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const SizedBox(width: 74),
              Expanded(
                child: _WasteFan(controller: controller, cardWidth: cardWidth),
              ),
              _StockPile(controller: controller, cardWidth: cardWidth),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < controller.state.columns.length; i++) ...[
                Expanded(
                  child: _CategoryColumn(
                    controller: controller,
                    columnIndex: i,
                    cardWidth: cardWidth,
                  ),
                ),
                if (i != controller.state.columns.length - 1)
                  SizedBox(width: columnGap),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _CategoryColumn extends StatelessWidget {
  const _CategoryColumn({
    required this.controller,
    required this.columnIndex,
    required this.cardWidth,
  });

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
    final stackStep = cardHeight * 0.25;
    
    final playableSelected =
        state.selectedCardId != null &&
        controller.canDropOnCategory(state.selectedCardId!, columnIndex);
    final active =
        state.activeCategoryId == category.id ||
        state.hintCategoryId == category.id ||
        playableSelected;

    final isDraggingCard = controller.draggingCardId != null;
    final isValidDestination = isDraggingCard &&
        controller.canDropOnColumn(controller.draggingCardId!, columnIndex);

    return DragTarget<String>(
      key: columnKey,
      onWillAcceptWithDetails: (details) {
        return controller.canDropOnColumn(details.data, columnIndex);
      },
      onAcceptWithDetails: (details) {
        controller.onCardDropped(details.data, columnIndex, details.offset);
      },
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;
        final isInvalidHover = isHovering && !isValidDestination;
        final isEmptyStack = column.length <= 1;
        final glowing = active || isHovering;

        BoxBorder borderStyle;
        List<BoxShadow>? boxShadows;

        if (isValidDestination) {
          if (isHovering) {
            if (isEmptyStack) {
              borderStyle = Border.all(color: const Color(0xFFFFD700), width: 2.0);
              boxShadows = [
                BoxShadow(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                  blurRadius: 16,
                  spreadRadius: 2,
                )
              ];
            } else {
              borderStyle = Border.all(color: const Color(0xFF4CAF50), width: 2.0);
              boxShadows = [
                BoxShadow(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.4),
                  blurRadius: 16,
                  spreadRadius: 2,
                )
              ];
            }
          } else {
            borderStyle = Border.all(
              color: const Color(0xFFFFD700).withValues(alpha: 0.4),
              width: 1.5,
            );
            boxShadows = [
              BoxShadow(
                color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                blurRadius: 8,
              )
            ];
          }
        } else if (isInvalidHover) {
          borderStyle = Border.all(
            color: Colors.red.withValues(alpha: 0.3),
            width: 1.5,
          );
          boxShadows = null;
        } else {
          borderStyle = Border.all(color: Colors.transparent, width: 1.5);
          boxShadows = glowing
              ? [
                  BoxShadow(
                    color: GameColors.categoryActiveBorder.withValues(alpha: 0.35),
                    blurRadius: 18,
                    spreadRadius: 1,
                  )
                ]
              : null;
        }

        return GestureDetector(
          onTap: () => controller.tapCategory(columnIndex),
          child: AnimatedScale(
            scale: isValidDestination && isHovering && !isEmptyStack ? 1.02 : 1.0,
            duration: const Duration(milliseconds: 140),
            curve: Curves.easeOut,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              curve: Curves.easeOut,
              padding: const EdgeInsets.only(top: 30),
              decoration: BoxDecoration(
                color: isHovering && isValidDestination && isEmptyStack
                    ? Colors.white.withValues(alpha: 0.08)
                    : isInvalidHover
                        ? Colors.black.withValues(alpha: 0.05)
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: borderStyle,
                boxShadow: boxShadows,
              ),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topCenter,
                children: [
                  Positioned(
                    top: -28,
                    left: 0,
                    right: 0,
                    child: _CategoryTab(
                      name: category.name,
                      progress: state.categoryProgress[category.id] ?? 0,
                      required: category.requiredItemCount,
                      completed: state.completedCategories.contains(category.id),
                    ),
                  ),
                  SizedBox(
                    height: cardHeight + stackStep * (column.length + 1),
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
                            child: Center(
                              child: _PlayableCard(
                                controller: controller,
                                cardId: column[i],
                                cardWidth: cardWidth,
                                isTopCard: i == column.length - 1,
                              ),
                            ),
                          ),
                        if (isValidDestination && isHovering && !isEmptyStack)
                          Positioned(
                            top: (column.length - 1) * stackStep,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: _DropIndicator(cardWidth: cardWidth),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DropIndicator extends StatelessWidget {
  const _DropIndicator({required this.cardWidth});

  final double cardWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: cardWidth,
      height: cardWidth * 1.38,
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFF4CAF50).withValues(alpha: 0.6),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.arrow_downward_rounded,
            color: Color(0xFF4CAF50),
            size: 20,
          ),
          const SizedBox(height: 4),
          Text(
            'DROP HERE',
            style: TextStyle(
              color: const Color(0xFF4CAF50),
              fontWeight: FontWeight.w900,
              fontSize: cardWidth * 0.12,
            ),
          ),
        ],
      ),
    );
  }
}

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
            child: PuzzleCardWidget(
              card: card,
              width: cardWidth,
              isFaceUp: true,
              isDragging: true,
            ),
          ),
        ),
        childWhenDragging: Opacity(
          opacity: 0.0,
          child: child,
        ),
        onDragStarted: () {
          controller.onDragStart(cardId);
        },
        onDragEnd: (details) {
          // Cleanup handled in onCardDropped or onDragCanceled
        },
        onDraggableCanceled: (velocity, offset) {
          controller.onDragCanceled(cardId, offset);
        },
        child: child,
      ),
    );
  }
}

class _WasteFan extends StatelessWidget {
  const _WasteFan({required this.controller, required this.cardWidth});

  final PlayScreenController controller;
  final double cardWidth;

  @override
  Widget build(BuildContext context) {
    final waste = controller.state.waste;
    if (waste.isEmpty) return const SizedBox.shrink();
    final visible = waste.length <= 3 ? waste : waste.sublist(waste.length - 3);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        for (var i = 0; i < visible.length; i++)
          Positioned(
            left: i * cardWidth * 0.32,
            bottom: 0,
            child: _PlayableCard(
              controller: controller,
              cardId: visible[i],
              cardWidth: cardWidth,
              isTopCard: i == visible.length - 1,
            ),
          ),
      ],
    );
  }
}

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
          for (var i = 2; i >= 0; i--)
            Transform.translate(
              offset: Offset(0, i * 2.0),
              child: Opacity(
                opacity: count > i ? 1 : 0.22,
                child: PuzzleCardWidget(
                  card: null,
                  width: cardWidth,
                  isFaceUp: false,
                ),
              ),
            ),
          if (count > 0)
            Positioned(top: 4, right: 4, child: _CountBadge(text: '$count')),
        ],
      ),
    );
  }
}

class _CategoryTab extends StatelessWidget {
  const _CategoryTab({
    required this.name,
    required this.progress,
    required this.required,
    required this.completed,
  });

  final String name;
  final int progress;
  final int required;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      padding: const EdgeInsets.fromLTRB(8, 5, 8, 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [GameColors.categoryHeader, GameColors.categoryHeaderDark],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFFF0A6), width: 1.2),
      ),
      child: Column(
        children: [
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF3A210C),
              fontWeight: FontWeight.w800,
              fontSize: 14,
              height: 1,
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (completed)
                const Icon(
                  Icons.workspace_premium_rounded,
                  color: GameColors.textDark,
                  size: 13,
                ),
              Text(
                '$progress/$required',
                style: const TextStyle(
                  color: Color(0xFF3A210C),
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                  height: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InstructionBar extends StatelessWidget {
  const _InstructionBar({required this.controller});

  final PlayScreenController controller;

  @override
  Widget build(BuildContext context) {
    final activeId = controller.state.activeCategoryId;
    final category = activeId == null
        ? null
        : controller.state.puzzle.categoryById(activeId);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: GameColors.instructionBar,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              color: GameColors.movesRibbon,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.info_rounded, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
                children: [
                  const TextSpan(text: 'Find all cards that belong to\n'),
                  TextSpan(
                    text: category?.name ?? 'the categories',
                    style: const TextStyle(color: GameColors.categoryHeader),
                  ),
                ],
              ),
            ),
          ),
          const Icon(
            Icons.workspace_premium_rounded,
            color: GameColors.categoryHeader,
            size: 20,
          ),
        ],
      ),
    );
  }
}

class _BottomControls extends StatelessWidget {
  const _BottomControls({required this.controller});

  final PlayScreenController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Row(
        children: [
          Expanded(
            child: _ActionButton(
              label: 'Hint',
              icon: Icons.lightbulb_rounded,
              color: GameColors.hintBlue,
              badge: controller.state.hintsRemaining,
              onTap: controller.useHint,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _ActionButton(
              label: 'Undo',
              icon: Icons.undo_rounded,
              color: GameColors.undoGrey,
              badge: controller.state.undoRemaining,
              onTap: controller.undo,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _ActionButton(
              label: 'Shuffle',
              icon: Icons.shuffle_rounded,
              color: GameColors.shuffleOrange,
              badge: controller.state.shufflesRemaining,
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
    required this.color,
    required this.badge,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final int badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 52,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.32),
                  blurRadius: 6,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 24),
                const SizedBox(width: 7),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (badge > 0)
            Positioned(
              right: -5,
              top: -9,
              child: _CountBadge(text: '$badge', red: true),
            ),
        ],
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.text, this.red = false});

  final String text;
  final bool red;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: red ? GameColors.badgeRed : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          color: red ? Colors.white : GameColors.textDark,
          fontWeight: FontWeight.w900,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _StatusOverlay extends StatelessWidget {
  const _StatusOverlay({required this.controller});

  final PlayScreenController controller;

  @override
  Widget build(BuildContext context) {
    final won = controller.state.status == GameStatus.won;
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.42),
        alignment: Alignment.center,
        child: Container(
          width: 280,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: GameColors.cardFace,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                won ? Icons.emoji_events_rounded : Icons.timer_off_rounded,
                color: won ? GameColors.crownGold : GameColors.badgeRed,
                size: 52,
              ),
              const SizedBox(height: 8),
              Text(
                won ? 'Level Complete' : 'Out of Moves',
                style: const TextStyle(
                  color: GameColors.textDark,
                  fontWeight: FontWeight.w900,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                won
                    ? 'Level ${controller.level} cleared with ${controller.state.movesRemaining} moves left.'
                    : 'Undo a move or retry this puzzle.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF5B4A3F),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _DialogButton(
                      label: 'Retry',
                      onTap: controller.retryLevel,
                      color: GameColors.undoGrey,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _DialogButton(
                      label: won ? 'Next' : 'Undo',
                      onTap: won ? controller.retryLevel : controller.undo,
                      color: GameColors.shuffleOrange,
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
  const _DialogButton({
    required this.label,
    required this.onTap,
    required this.color,
  });

  final String label;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}

class _AnimationOverlay extends StatelessWidget {
  const _AnimationOverlay({required this.controller});

  final PlayScreenController controller;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columnGap = width < 380 ? 8.0 : 12.0;
        final horizontalPadding = width < 380 ? 12.0 : 18.0;
        final cardWidth =
            (width - horizontalPadding * 2 - columnGap * 3) / 4;
        final clampedCardWidth = cardWidth.clamp(72.0, 104.0);

        return Stack(
          children: [
            CardAnimationWidget(
              state: controller.animatingCard!,
              cardWidth: clampedCardWidth,
              controller: controller,
            ),
          ],
        );
      },
    );
  }
}

class CardAnimationWidget extends StatefulWidget {
  final AnimatingCardState state;
  final double cardWidth;
  final PlayScreenController controller;

  const CardAnimationWidget({
    super.key,
    required this.state,
    required this.cardWidth,
    required this.controller,
  });

  @override
  State<CardAnimationWidget> createState() => _CardAnimationWidgetState();
}

class _CardAnimationWidgetState extends State<CardAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _positionAnimation;
  late Animation<double> _shakeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 240),
      vsync: this,
    );

    _positionAnimation = Tween<Offset>(
      begin: widget.state.startOffset,
      end: widget.state.endOffset,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimation = Tween<double>(
      begin: widget.state.isShake ? 1.06 : 1.03,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _rotationAnimation = Tween<double>(
      begin: widget.state.isShake ? 0.04 : 0.02,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    if (widget.state.isShake) {
      _shakeAnimation = TweenSequence<double>([
        TweenSequenceItem(tween: Tween(begin: 0.0, end: 10.0), weight: 1),
        TweenSequenceItem(tween: Tween(begin: 10.0, end: -10.0), weight: 2),
        TweenSequenceItem(tween: Tween(begin: -10.0, end: 6.0), weight: 2),
        TweenSequenceItem(tween: Tween(begin: 6.0, end: -6.0), weight: 2),
        TweenSequenceItem(tween: Tween(begin: -6.0, end: 0.0), weight: 1),
      ]).animate(CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.linear),
      ));
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
