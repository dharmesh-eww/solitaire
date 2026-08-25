import '../../../core/puzzle/puzzle_data.dart';
import '../../../core/puzzle/puzzle_generator.dart';
import '../model/card_location.dart';
import '../model/game_state.dart';

enum GameActionResult { success, invalid, noMovesLeft, gameOver }

class GameEngine {
  GameEngine(this.state);

  final GameState state;

  PuzzleData get puzzle => state.puzzle;

  bool get isInteractive => state.status == GameStatus.playing;

  bool isFaceUp(String cardId) => !state.faceDownIds.contains(cardId);

  bool isPlayable(String cardId) {
    if (!isInteractive) return false;
    final card = puzzle.cardById(cardId);
    if (card == null) return false;
    // Distractor cards can never be played
    if (card.isDistractor) return false;
    if (!isFaceUp(cardId)) return false;

    final location = locateCard(cardId);
    if (location == null) return false;

    switch (location.zone) {
      case CardZone.waste:
        return state.waste.isNotEmpty && state.waste.last == cardId;
      case CardZone.stock:
        return false;
      case CardZone.tableau:
        final column = state.columns[location.columnIndex!];
        return column.isNotEmpty && column.last == cardId;
    }
  }

  CardLocation? locateCard(String cardId) {
    if (state.waste.contains(cardId)) {
      return const CardLocation(zone: CardZone.waste);
    }
    if (state.stock.contains(cardId)) {
      return const CardLocation(zone: CardZone.stock);
    }
    for (var i = 0; i < state.columns.length; i++) {
      if (state.columns[i].contains(cardId)) {
        return CardLocation(zone: CardZone.tableau, columnIndex: i);
      }
    }
    return null;
  }

  int columnIndexForCategory(String categoryId) {
    // 1. If category header is already placed in a column, return that column
    for (var i = 0; i < state.columns.length; i++) {
      final headerId = state.categoryHeaders[i];
      if (headerId != null) {
        final headerCard = puzzle.cardById(headerId);
        if (headerCard != null && headerCard.categoryId == categoryId) {
          return i;
        }
      }
    }
    // 2. Otherwise return first column with empty header
    for (var i = 0; i < state.columns.length; i++) {
      if (state.categoryHeaders[i] == null) {
        return i;
      }
    }
    return -1;
  }

  String? categoryIdForColumn(int columnIndex) {
    if (columnIndex < 0 || columnIndex >= state.columns.length) {
      return null;
    }
    final headerId = state.categoryHeaders[columnIndex];
    if (headerId != null) {
      final headerCard = puzzle.cardById(headerId);
      return headerCard?.categoryId;
    }
    return null;
  }

  bool isCategoryCompleted(String categoryId) {
    return state.completedCategories.contains(categoryId);
  }

  int categoryRequiredCount(String categoryId) {
    return puzzle.categoryById(categoryId)?.requiredItemCount ?? 0;
  }

  int categoryPlacedCount(String categoryId) {
    return state.categoryProgress[categoryId] ?? 0;
  }

  bool canDropOnCategoryHeader(String cardId, int columnIndex) {
    if (!isPlayable(cardId)) return false;

    final card = puzzle.cardById(cardId);
    if (card == null || !card.isCategoryHeader) return false;

    // Header slot must be empty
    if (state.categoryHeaders[columnIndex] != null) return false;

    // Must not already be placed in another column
    if (state.categoryHeaders.values.contains(cardId)) return false;

    return true;
  }

  bool canDropOnPlayableStack(String cardId, int columnIndex) {
    if (!isPlayable(cardId)) return false;

    final card = puzzle.cardById(cardId);
    if (card == null || card.isCategoryHeader || card.isDistractor) return false;

    // Check if the card's category is already completed
    if (isCategoryCompleted(card.categoryId)) return false;

    final headerCardId = state.categoryHeaders[columnIndex];
    if (headerCardId == null) return false;

    final headerCard = puzzle.cardById(headerCardId);
    if (headerCard == null) return false;

    // Regular card MUST match the category of the placed header card!
    return card.categoryId == headerCard.categoryId;
  }

  bool canDropOnColumn(String cardId, int columnIndex) {
    return canDropOnCategoryHeader(cardId, columnIndex) ||
        canDropOnPlayableStack(cardId, columnIndex);
  }

  bool canDropOnCategory(String cardId, String categoryId) {
    final columnIndex = columnIndexForCategory(categoryId);
    if (columnIndex < 0) return false;
    return canDropOnColumn(cardId, columnIndex);
  }

  void selectCard(String? cardId) {
    if (!isInteractive) return;
    state.hintCardId = null;
    state.hintCategoryId = null;
    if (cardId != null && !isPlayable(cardId)) return;
    state.selectedCardId = cardId;
  }

  GameActionResult tapCategory(int columnIndex) {
    final selected = state.selectedCardId;
    if (selected == null) return GameActionResult.invalid;
    return moveCardToCategory(selected, columnIndex, consumeMove: true);
  }

  GameActionResult moveCardToCategory(String cardId, int columnIndex, {required bool consumeMove}) {
    if (!isInteractive) return GameActionResult.gameOver;
    if (state.movesRemaining <= 0 && consumeMove) {
      state.status = GameStatus.outOfMoves;
      return GameActionResult.noMovesLeft;
    }

    if (!canDropOnColumn(cardId, columnIndex)) {
      return GameActionResult.invalid;
    }

    _pushUndoSnapshot();

    final removed = _removeCard(cardId);
    if (!removed) {
      state.undoHistory.removeLast();
      return GameActionResult.invalid;
    }

    final card = puzzle.cardById(cardId)!;
    final categoryId = card.categoryId;

    if (card.isCategoryHeader && state.categoryHeaders[columnIndex] == null) {
      // Placed as the category header for this column!
      state.categoryHeaders[columnIndex] = cardId;
    } else {
      // Placed in the tableau stack of this column!
      state.columns[columnIndex].add(cardId);
      state.categoryProgress[categoryId] = (state.categoryProgress[categoryId] ?? 0) + 1;

      if (categoryPlacedCount(categoryId) >= categoryRequiredCount(categoryId)) {
        state.completedCategories.add(categoryId);
      }
    }

    state.selectedCardId = null;
    state.hintCardId = null;
    state.hintCategoryId = null;
    _updateActiveCategory();

    if (consumeMove) {
      state.movesRemaining--;
      if (state.movesRemaining <= 0 && !_isWin()) {
        state.status = GameStatus.outOfMoves;
      }
    }

    if (_isWin()) {
      state.status = GameStatus.won;
    }

    return GameActionResult.success;
  }

  GameActionResult drawFromStock() {
    if (!isInteractive) return GameActionResult.gameOver;
    if (state.movesRemaining <= 0) {
      state.status = GameStatus.outOfMoves;
      return GameActionResult.noMovesLeft;
    }
    if (state.stock.isEmpty) return GameActionResult.invalid;

    _pushUndoSnapshot();
    final cardId = state.stock.removeLast();
    state.faceDownIds.remove(cardId);
    state.waste.add(cardId);
    state.movesRemaining--;
    state.selectedCardId = null;
    state.hintCardId = null;
    state.hintCategoryId = null;

    if (state.movesRemaining <= 0 && !_isWin()) {
      state.status = GameStatus.outOfMoves;
    }

    return GameActionResult.success;
  }

  GameActionResult useHint() {
    if (!isInteractive) return GameActionResult.gameOver;
    if (state.hintsRemaining <= 0) return GameActionResult.invalid;

    final hint = _findHintMove();
    if (hint == null) return GameActionResult.invalid;

    state.hintsRemaining--;
    state.hintCardId = hint.cardId;
    state.hintCategoryId = hint.categoryId;
    state.activeCategoryId = hint.categoryId;
    state.selectedCardId = hint.cardId;
    return GameActionResult.success;
  }

  GameActionResult undo() {
    if (!isInteractive && state.status != GameStatus.outOfMoves) {
      return GameActionResult.gameOver;
    }
    if (state.undoRemaining <= 0 || state.undoHistory.isEmpty) {
      return GameActionResult.invalid;
    }

    final snapshot = state.undoHistory.removeLast();
    state.restore(snapshot);
    state.undoRemaining--;
    if (state.status == GameStatus.outOfMoves && state.movesRemaining > 0) {
      state.status = GameStatus.playing;
    }
    return GameActionResult.success;
  }

  GameActionResult shuffleTableau() {
    if (!isInteractive) return GameActionResult.gameOver;
    if (state.shufflesRemaining <= 0) return GameActionResult.invalid;

    _pushUndoSnapshot();

    final movableCards = <String>[];
    final slots = <({int column, int index})>[];

    for (var col = 0; col < state.columns.length; col++) {
      final column = state.columns[col];
      for (var i = 1; i < column.length; i++) {
        final cardId = column[i];
        if (isFaceUp(cardId) && isPlayable(cardId)) {
          movableCards.add(cardId);
          slots.add((column: col, index: i));
        }
      }
    }

    if (movableCards.length < 2) {
      state.undoHistory.removeLast();
      return GameActionResult.invalid;
    }

    movableCards.shuffle();
    for (var i = 0; i < slots.length; i++) {
      final slot = slots[i];
      state.columns[slot.column][slot.index] = movableCards[i];
    }

    state.shufflesRemaining--;
    state.selectedCardId = null;
    state.hintCardId = null;
    state.hintCategoryId = null;
    return GameActionResult.success;
  }

  void retryLevel() {
    final fresh = GameState.fromPuzzle(state.puzzle);
    state
      ..columns = fresh.columns
      ..categoryHeaders = fresh.categoryHeaders
      ..stock = fresh.stock
      ..waste = fresh.waste
      ..faceDownIds = fresh.faceDownIds
      ..categoryProgress = fresh.categoryProgress
      ..completedCategories = fresh.completedCategories
      ..movesRemaining = fresh.movesRemaining
      ..hintsRemaining = fresh.hintsRemaining
      ..undoRemaining = fresh.undoRemaining
      ..shufflesRemaining = fresh.shufflesRemaining
      ..selectedCardId = null
      ..activeCategoryId = fresh.activeCategoryId
      ..hintCardId = null
      ..hintCategoryId = null
      ..status = GameStatus.playing
      ..undoHistory.clear();
  }

  static GameEngine forPuzzle(PuzzleData puzzle) {
    return GameEngine(GameState.fromPuzzle(puzzle));
  }

  static GameEngine forLevel(int level) {
    final puzzle = PuzzleGenerator.instance.generate(level: level);
    return GameEngine(GameState.fromPuzzle(puzzle));
  }

  bool _isWin() {
    return state.completedCategories.length == puzzle.categories.length;
  }

  void _updateActiveCategory() {
    for (final category in puzzle.categories) {
      if (!state.completedCategories.contains(category.id)) {
        state.activeCategoryId = category.id;
        return;
      }
    }
    state.activeCategoryId = null;
  }

  bool _removeCard(String cardId) {
    if (state.waste.contains(cardId)) {
      state.waste.remove(cardId);
      return true;
    }

    for (final entry in state.categoryHeaders.entries) {
      if (entry.value == cardId) {
        state.categoryHeaders[entry.key] = null;
        return true;
      }
    }

    for (var col = 0; col < state.columns.length; col++) {
      final column = state.columns[col];
      final index = column.indexOf(cardId);
      if (index != -1) {
        final card = puzzle.cardById(cardId);
        if (card != null && !card.isCategoryHeader) {
          final curProg = state.categoryProgress[card.categoryId] ?? 0;
          if (curProg > 0) {
            state.categoryProgress[card.categoryId] = curProg - 1;
            state.completedCategories.remove(card.categoryId);
          }
        }
        column.removeAt(index);
        if (column.isNotEmpty) {
          final revealedId = column.last;
          state.faceDownIds.remove(revealedId);
        }
        return true;
      }
    }
    return false;
  }

  void _pushUndoSnapshot() {
    state.undoHistory.add(state.capture());
    if (state.undoHistory.length > 30) {
      state.undoHistory.removeAt(0);
    }
  }

  _HintMove? _findHintMove() {
    final candidates = <String>[
      if (state.waste.isNotEmpty && isPlayable(state.waste.last)) state.waste.last,
      for (var col = 0; col < state.columns.length; col++)
        if (state.columns[col].isNotEmpty) state.columns[col].last else '',
    ].where((id) => id.isNotEmpty && isPlayable(id));

    for (final cardId in candidates) {
      final card = puzzle.cardById(cardId);
      if (card == null || card.isDistractor) continue;
      if (isCategoryCompleted(card.categoryId)) continue;
      final columnIndex = columnIndexForCategory(card.categoryId);
      if (columnIndex >= 0) {
        return _HintMove(cardId: cardId, categoryId: card.categoryId);
      }
    }
    return null;
  }
}

class _HintMove {
  const _HintMove({required this.cardId, required this.categoryId});
  final String cardId;
  final String categoryId;
}
