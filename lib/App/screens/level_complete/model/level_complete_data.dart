class LevelCompleteData {
  const LevelCompleteData({
    required this.levelNumber,
    required this.stars,
    required this.movesUsed,
    required this.movesRemaining,
    required this.coinsReward,
    required this.nextLevel,
    required this.bestStars,
    required this.isNewBest,
  });

  final int levelNumber;
  final int stars; // 1-3
  final int movesUsed;
  final int movesRemaining;
  final int coinsReward;
  final int nextLevel;
  final int bestStars;
  final bool isNewBest;

  int get totalMoves => movesUsed + movesRemaining;
  int get score => (stars * 1000) + (movesRemaining * 60) + (coinsReward * 5);

  String get performanceTitle {
    if (stars >= 3) return 'PERFECT!';
    if (stars == 2) return 'GREAT JOB!';
    return 'COMPLETED!';
  }

  static const LevelCompleteData fallback = LevelCompleteData(
    levelNumber: 1,
    stars: 3,
    movesUsed: 12,
    movesRemaining: 18,
    coinsReward: 125,
    nextLevel: 2,
    bestStars: 3,
    isNewBest: true,
  );
}