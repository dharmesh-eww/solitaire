import '../../../core/puzzle/puzzle_data.dart';
import 'card_location.dart';

class GameSnapshot {
  const GameSnapshot({
    required this.columns,
    required this.stock,
    required this.waste,
    required this.faceDownIds,
    required this.categoryProgress,
    required this.completedCategories,
    required this.movesRemaining,
    required this.hintsRemaining,
    required this.undoRemaining,
    required this.shufflesRemaining,
    required this.selectedCardId,
    required this.activeCategoryId,
    required this.hintCardId,
    required this.hintCategoryId,
    required this.status,
  });

  final List<List<String>> columns;
  final List<String> stock;
  final List<String> waste;
  final Set<String> faceDownIds;
  final Map<String, int> categoryProgress;
  final Set<String> completedCategories;
  final int movesRemaining;
  final int hintsRemaining;
  final int undoRemaining;
  final int shufflesRemaining;
  final String? selectedCardId;
  final String? activeCategoryId;
  final String? hintCardId;
  final String? hintCategoryId;
  final GameStatus status;
}

class GameState {
  GameState({
    required this.puzzle,
    required this.columns,
    required this.stock,
    required this.waste,
    required this.faceDownIds,
    required this.categoryProgress,
    required this.completedCategories,
    required this.movesRemaining,
    required this.hintsRemaining,
    required this.undoRemaining,
    required this.shufflesRemaining,
    this.selectedCardId,
    this.activeCategoryId,
    this.hintCardId,
    this.hintCategoryId,
    this.status = GameStatus.playing,
    List<GameSnapshot>? undoHistory,
  }) : undoHistory = undoHistory ?? [];

  final PuzzleData puzzle;
  List<List<String>> columns;
  List<String> stock;
  List<String> waste;
  Set<String> faceDownIds;
  Map<String, int> categoryProgress;
  Set<String> completedCategories;
  int movesRemaining;
  int hintsRemaining;
  int undoRemaining;
  int shufflesRemaining;
  String? selectedCardId;
  String? activeCategoryId;
  String? hintCardId;
  String? hintCategoryId;
  GameStatus status;
  final List<GameSnapshot> undoHistory;

  GameSnapshot capture() {
    return GameSnapshot(
      columns: columns.map(List<String>.from).toList(),
      stock: List<String>.from(stock),
      waste: List<String>.from(waste),
      faceDownIds: Set<String>.from(faceDownIds),
      categoryProgress: Map<String, int>.from(categoryProgress),
      completedCategories: Set<String>.from(completedCategories),
      movesRemaining: movesRemaining,
      hintsRemaining: hintsRemaining,
      undoRemaining: undoRemaining,
      shufflesRemaining: shufflesRemaining,
      selectedCardId: selectedCardId,
      activeCategoryId: activeCategoryId,
      hintCardId: hintCardId,
      hintCategoryId: hintCategoryId,
      status: status,
    );
  }

  void restore(GameSnapshot snapshot) {
    columns = snapshot.columns.map(List<String>.from).toList();
    stock = List<String>.from(snapshot.stock);
    waste = List<String>.from(snapshot.waste);
    faceDownIds = Set<String>.from(snapshot.faceDownIds);
    categoryProgress = Map<String, int>.from(snapshot.categoryProgress);
    completedCategories = Set<String>.from(snapshot.completedCategories);
    movesRemaining = snapshot.movesRemaining;
    hintsRemaining = snapshot.hintsRemaining;
    undoRemaining = snapshot.undoRemaining;
    shufflesRemaining = snapshot.shufflesRemaining;
    selectedCardId = snapshot.selectedCardId;
    activeCategoryId = snapshot.activeCategoryId;
    hintCardId = snapshot.hintCardId;
    hintCategoryId = snapshot.hintCategoryId;
    status = snapshot.status;
  }

  factory GameState.fromPuzzle(PuzzleData puzzle) {
    final layout = puzzle.initialLayout;
    final columns = layout.tableauColumns.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final categoryProgress = {
      for (final category in puzzle.categories) category.id: 0,
    };

    return GameState(
      puzzle: puzzle,
      columns: columns.map((entry) => List<String>.from(entry.value)).toList(),
      stock: List<String>.from(layout.stockCardIds),
      waste: List<String>.from(layout.wasteCardIds),
      faceDownIds: Set<String>.from(layout.faceDownCardIds),
      categoryProgress: categoryProgress,
      completedCategories: {},
      movesRemaining: puzzle.maxMoves,
      hintsRemaining: puzzle.hintCount,
      undoRemaining: puzzle.undoCount,
      shufflesRemaining: puzzle.shuffleCount,
      activeCategoryId: _initialActiveCategory(puzzle),
    );
  }

  static String? _initialActiveCategory(PuzzleData puzzle) {
    final incomplete = puzzle.categories.where(
      (category) => category.requiredItemCount > 0,
    );
    return incomplete.isEmpty ? null : incomplete.first.id;
  }
}
