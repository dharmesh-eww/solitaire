enum PuzzleDifficulty { easy, easyMedium, medium, mediumHard, hard, expert }

class DifficultyConfig {
  const DifficultyConfig({
    required this.difficulty,
    required this.categoryCount,
    required this.itemsPerCategory,
    required this.distractorCount,
    required this.faceDownRatio,
    required this.maxMovesMultiplier,
  });

  final PuzzleDifficulty difficulty;
  final int categoryCount;
  final int itemsPerCategory;
  final int distractorCount;
  final double faceDownRatio;
  final double maxMovesMultiplier;

  static DifficultyConfig forLevel(int level) {
    if (level <= 10) {
      return DifficultyConfig(
        difficulty: PuzzleDifficulty.easy,
        categoryCount: 3,
        itemsPerCategory: 4,
        distractorCount: 2,
        faceDownRatio: 0.15,
        maxMovesMultiplier: 2.4,
      );
    }
    if (level <= 25) {
      return DifficultyConfig(
        difficulty: PuzzleDifficulty.easyMedium,
        categoryCount: 4,
        itemsPerCategory: 4,
        distractorCount: 4,
        faceDownRatio: 0.25,
        maxMovesMultiplier: 2.1,
      );
    }
    if (level <= 50) {
      return DifficultyConfig(
        difficulty: PuzzleDifficulty.medium,
        categoryCount: 5,
        itemsPerCategory: level <= 35 ? 4 : 5,
        distractorCount: 6,
        faceDownRatio: 0.35,
        maxMovesMultiplier: 1.9,
      );
    }
    if (level <= 100) {
      return DifficultyConfig(
        difficulty: PuzzleDifficulty.mediumHard,
        categoryCount: 5,
        itemsPerCategory: 5,
        distractorCount: 8,
        faceDownRatio: 0.42,
        maxMovesMultiplier: 1.7,
      );
    }
    if (level <= 250) {
      return DifficultyConfig(
        difficulty: PuzzleDifficulty.hard,
        categoryCount: 5,
        itemsPerCategory: 5 + ((level - 101) ~/ 75).clamp(0, 1),
        distractorCount: 10 + ((level - 101) ~/ 30),
        faceDownRatio: 0.48,
        maxMovesMultiplier: 1.55,
      );
    }

    final tier = (level - 251) ~/ 50;
    return DifficultyConfig(
      difficulty: PuzzleDifficulty.expert,
      categoryCount: 5,
      itemsPerCategory: (5 + tier ~/ 2).clamp(5, 8),
      distractorCount: 12 + tier * 2,
      faceDownRatio: (0.5 + tier * 0.02).clamp(0.5, 0.65),
      maxMovesMultiplier: (1.45 - tier * 0.05).clamp(1.1, 1.45),
    );
  }
}
