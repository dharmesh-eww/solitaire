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
}