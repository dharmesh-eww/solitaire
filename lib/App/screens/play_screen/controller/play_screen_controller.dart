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

  bool isPlayable(String cardId) => engine.isPlayable(cardId);

  bool isFaceUp(String cardId) => engine.isFaceUp(cardId);

  bool canDropOnColumn(String cardId, int columnIndex) {
    return engine.canDropOnColumn(cardId, columnIndex);
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
        update();
      },
    );
    update();
  }

  void onCardDropped(String cardId, int columnIndex, Offset releaseOffset) {
    draggingCardId = null;

    final columnKey = columnKeys[columnIndex];
    final RenderBox? columnBox = columnKey?.currentContext?.findRenderObject() as RenderBox?;
    final columnOffset = columnBox?.localToGlobal(Offset.zero) ?? releaseOffset;

    final double cardWidth = columnBox?.size.width ?? 80.0;
    final double cardHeight = cardWidth * 1.38;
    final double stackStep = cardHeight * 0.25;

    final column = state.columns[columnIndex];
    final destY = columnOffset.dy + 30.0 + (column.length - 1) * stackStep;
    final endOffset = Offset(columnOffset.dx, destY);

    animatingCard = AnimatingCardState(
      cardId: cardId,
      startOffset: releaseOffset,
      endOffset: endOffset,
      isShake: false,
      onComplete: () {
        animatingCard = null;
        moveCardToCategory(cardId, columnIndex);
        hiddenCardId = null;
        update();
      },
    );
    update();
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
