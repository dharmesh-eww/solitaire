import 'package:flutter/material.dart';
import 'package:statekit/statekit.dart';
import '../../level_complete/model/level_complete_data.dart';
import '../binding/play_screen_binding.dart';
import '../engine/game_engine.dart';
import '../model/game_state.dart';
import '../model/card_location.dart';

class AnimatingCardState {
  final String cardId;
  final Offset startOffset;
  final Offset endOffset;
  final bool isShake;
  final VoidCallback onComplete;

  AnimatingCardState({
    required this.cardId,
    required this.startOffset,
    required this.endOffset,
    required this.isShake,
    required this.onComplete,
  });
}

class PlayScreenController extends StateController<PlayScreenBinding> {
  PlayScreenController({int level = 1}) : engine = GameEngine.forLevel(level);

  final GameEngine engine;

  GameState get state => engine.state;
  int get level => state.puzzle.level;

  String? draggingCardId;
  String? hiddenCardId;
  AnimatingCardState? animatingCard;
  bool _hasTriggeredWin = false;

  final Map<String, GlobalKey> cardKeys = {};
  final Map<int, GlobalKey> columnKeys = {};
  final Map<int, GlobalKey> headerKeys = {};
  final Map<int, GlobalKey> playableStackKeys = {};

  bool isPlayable(String cardId) => engine.isPlayable(cardId);

  bool isFaceUp(String cardId) => engine.isFaceUp(cardId);

  bool canDropOnColumn(String cardId, int columnIndex) {
    return engine.canDropOnColumn(cardId, columnIndex);
  }

  bool canDropOnCategoryHeader(String cardId, int columnIndex) {
    return engine.canDropOnCategoryHeader(cardId, columnIndex);
  }

  bool canDropOnPlayableStack(String cardId, int columnIndex) {
    return engine.canDropOnPlayableStack(cardId, columnIndex);
  }

  bool canDropOnCategory(String cardId, int columnIndex) {
    return canDropOnColumn(cardId, columnIndex);
  }

  void selectCard(String? cardId) {
    engine.selectCard(cardId);
    update();
  }

  void tapCategory(int columnIndex) {
    engine.tapCategory(columnIndex);
    _checkGameWin();
    update();
  }

  void tapCategoryHeader(int columnIndex) {
    final selected = state.selectedCardId;
    if (selected != null && canDropOnCategoryHeader(selected, columnIndex)) {
      moveCardToCategory(selected, columnIndex);
    }
  }

  void tapPlayableStack(int columnIndex) {
    final selected = state.selectedCardId;
    if (selected != null && canDropOnPlayableStack(selected, columnIndex)) {
      moveCardToCategory(selected, columnIndex);
    }
  }

  void moveCardToCategory(String cardId, int columnIndex) {
    engine.moveCardToCategory(cardId, columnIndex, consumeMove: true);
    _checkGameWin();
    update();
  }

  void _checkGameWin() {
    if (state.status == GameStatus.won && !_hasTriggeredWin) {
      _hasTriggeredWin = true;
      final maxMoves = state.puzzle.maxMoves;
      final remaining = state.movesRemaining;
      final used = (maxMoves - remaining).clamp(0, maxMoves);

      int stars = 1;
      if (remaining >= (maxMoves * 0.35).round()) {
        stars = 3;
      } else if (remaining >= (maxMoves * 0.15).round()) {
        stars = 2;
      }

      final coinsReward = 50 + (stars * 25) + (remaining * 2);

      final data = LevelCompleteData(
        levelNumber: level,
        stars: stars,
        movesUsed: used,
        movesRemaining: remaining,
        coinsReward: coinsReward,
        nextLevel: level + 1,
        bestStars: stars,
        isNewBest: true,
      );

      // Brief delay so final card animation settles smoothly before transitioning
      Future.delayed(const Duration(milliseconds: 650), () {
        binding?.onLevelCompleted(data);
      });
    }
  }

  void onDragStart(String cardId) {
    draggingCardId = cardId;
    hiddenCardId = cardId;
    selectCard(cardId);
  }

  void onDragCanceled(String cardId, Offset releaseOffset) {
    draggingCardId = null;

    final key = cardKeys[cardId];
    final RenderBox? box = key?.currentContext?.findRenderObject() as RenderBox?;
    final endOffset = box?.localToGlobal(Offset.zero) ?? releaseOffset;

    animatingCard = AnimatingCardState(
      cardId: cardId,
      startOffset: releaseOffset,
      endOffset: endOffset,
      isShake: true,
      onComplete: () {
        animatingCard = null;
        hiddenCardId = null;
        draggingCardId = null;
        selectCard(null);
        update();
      },
    );
    update();
  }

  void onCardDroppedOnHeader(String cardId, int columnIndex, Offset releaseOffset) {
    draggingCardId = null;

    final headerKey = headerKeys[columnIndex];
    final RenderBox? headerBox = headerKey?.currentContext?.findRenderObject() as RenderBox?;
    final endOffset = headerBox?.localToGlobal(Offset.zero) ?? releaseOffset;

    animatingCard = AnimatingCardState(
      cardId: cardId,
      startOffset: releaseOffset,
      endOffset: endOffset,
      isShake: false,
      onComplete: () {
        animatingCard = null;
        hiddenCardId = null;
        draggingCardId = null;
        selectCard(null);
        moveCardToCategory(cardId, columnIndex);
        update();
      },
    );
    update();
  }

  void onCardDroppedOnPlayableStack(String cardId, int columnIndex, Offset releaseOffset) {
    draggingCardId = null;

    final stackKey = playableStackKeys[columnIndex];
    final RenderBox? stackBox = stackKey?.currentContext?.findRenderObject() as RenderBox?;
    final stackOffset = stackBox?.localToGlobal(Offset.zero) ?? releaseOffset;

    final double cardWidth = stackBox?.size.width ?? 80.0;
    final double cardHeight = cardWidth * 1.38;
    final double stackStep = cardHeight * 0.22;

    final double destY = stackOffset.dy + (state.columns[columnIndex].length * stackStep);
    final endOffset = Offset(stackOffset.dx, destY);

    animatingCard = AnimatingCardState(
      cardId: cardId,
      startOffset: releaseOffset,
      endOffset: endOffset,
      isShake: false,
      onComplete: () {
        animatingCard = null;
        hiddenCardId = null;
        draggingCardId = null;
        selectCard(null);
        moveCardToCategory(cardId, columnIndex);
        update();
      },
    );
    update();
  }

  void onCardDropped(String cardId, int columnIndex, Offset releaseOffset) {
    final card = state.puzzle.cardById(cardId);
    if (card != null && card.isCategoryHeader) {
      onCardDroppedOnHeader(cardId, columnIndex, releaseOffset);
    } else {
      onCardDroppedOnPlayableStack(cardId, columnIndex, releaseOffset);
    }
  }

  void drawFromStock() {
    engine.drawFromStock();
    update();
  }

  void useHint() {
    engine.useHint();
    update();
  }

  void undo() {
    if (!engine.isInteractive && state.status != GameStatus.outOfMoves) return;
    if (state.undoRemaining <= 0 || state.undoHistory.isEmpty) return;

    final snapshot = state.undoHistory.last;
    String? movedCardId;
    int? srcColIndex;
    int? destColIndex;

    for (var col = 0; col < state.columns.length; col++) {
      final currentColumn = state.columns[col];
      final snapshotColumn = snapshot.columns[col];

      if (currentColumn.length > snapshotColumn.length) {
        destColIndex = col;
        if (currentColumn.isNotEmpty) {
          movedCardId = currentColumn.last;
        }
      }
      if (currentColumn.length < snapshotColumn.length) {
        srcColIndex = col;
      }
    }

    if (movedCardId != null && srcColIndex != null && destColIndex != null) {
      final destKey = cardKeys[movedCardId];
      final RenderBox? destBox = destKey?.currentContext?.findRenderObject() as RenderBox?;
      final destOffset = destBox?.localToGlobal(Offset.zero);

      engine.undo();

      if (destOffset != null) {
        hiddenCardId = movedCardId;
        update();

        WidgetsBinding.instance.addPostFrameCallback((_) {
          final srcKey = cardKeys[movedCardId];
          final RenderBox? srcBox = srcKey?.currentContext?.findRenderObject() as RenderBox?;
          final srcOffset = srcBox?.localToGlobal(Offset.zero);

          if (srcOffset != null) {
            animatingCard = AnimatingCardState(
              cardId: movedCardId!,
              startOffset: destOffset,
              endOffset: srcOffset,
              isShake: false,
              onComplete: () {
                animatingCard = null;
                hiddenCardId = null;
                update();
              },
            );
            update();
          } else {
            hiddenCardId = null;
            update();
          }
        });
      } else {
        update();
      }
    } else {
      engine.undo();
      update();
    }
  }

  void shuffle() {
    engine.shuffleTableau();
    update();
  }

  void retryLevel() {
    _hasTriggeredWin = false;
    engine.retryLevel();
    update();
  }
}
