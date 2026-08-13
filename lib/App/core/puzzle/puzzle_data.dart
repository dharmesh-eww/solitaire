import 'puzzle_card.dart';
import 'puzzle_category.dart';
import 'puzzle_difficulty.dart';
import 'puzzle_initial_layout.dart';

class PuzzleData {
  const PuzzleData({
    required this.level,
    required this.difficulty,
    required this.categories,
    required this.cards,
    required this.maxMoves,
    required this.initialLayout,
    required this.solution,
    required this.seed,
    required this.hintCount,
    required this.undoCount,
    required this.shuffleCount,
  });

  final int level;
  final PuzzleDifficulty difficulty;
  final List<PuzzleCategory> categories;
  final List<PuzzleCard> cards;
  final int maxMoves;
  final PuzzleInitialLayout initialLayout;
  final Map<String, String> solution;
  final int seed;
  final int hintCount;
  final int undoCount;
  final int shuffleCount;

  PuzzleCard? cardById(String id) {
    for (final card in cards) {
      if (card.id == id) return card;
    }
    return null;
  }

  PuzzleCategory? categoryById(String id) {
    for (final category in categories) {
      if (category.id == id) return category;
    }
    return null;
  }
}
