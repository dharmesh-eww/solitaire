import '../../../core/puzzle/puzzle_difficulty.dart';

class LevelProgress {
  const LevelProgress({
    required this.levelNumber,
    required this.isUnlocked,
    this.isCompleted = false,
    this.stars = 0,
    this.bestScore,
    this.difficulty = PuzzleDifficulty.medium,
  });

  final int levelNumber;
  final bool isUnlocked;
  final bool isCompleted;
  final int stars; // 0-3 stars
  final int? bestScore;
  final PuzzleDifficulty difficulty;

  LevelProgress copyWith({
    int? levelNumber,
    bool? isUnlocked,
    bool? isCompleted,
    int? stars,
    int? bestScore,
    PuzzleDifficulty? difficulty,
  }) {
    return LevelProgress(
      levelNumber: levelNumber ?? this.levelNumber,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      isCompleted: isCompleted ?? this.isCompleted,
      stars: stars ?? this.stars,
      bestScore: bestScore ?? this.bestScore,
      difficulty: difficulty ?? this.difficulty,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'levelNumber': levelNumber,
      'isUnlocked': isUnlocked,
      'isCompleted': isCompleted,
      'stars': stars,
      'bestScore': bestScore,
      'difficulty': difficulty.index,
    };
  }

  factory LevelProgress.fromJson(Map<String, dynamic> json) {
    return LevelProgress(
      levelNumber: json['levelNumber'] as int,
      isUnlocked: json['isUnlocked'] as bool,
      isCompleted: json['isCompleted'] as bool,
      stars: json['stars'] as int,
      bestScore: json['bestScore'] as int?,
      difficulty: PuzzleDifficulty.values[json['difficulty'] as int],
    );
  }
}