import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/puzzle/puzzle_difficulty.dart';
import '../model/level_progress.dart';

class LevelSelectionRepository {
  static const String _progressKey = 'level_progress';
  static const String _currentLevelKey = 'current_level';
  static const String _coinsKey = 'player_coins';

  Future<List<LevelProgress>> loadLevelProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final progressJson = prefs.getString(_progressKey);
    
    if (progressJson == null) {
      return _generateInitialProgress();
    }

    try {
      final List<dynamic> decoded = jsonDecode(progressJson) as List<dynamic>;
      
      if (decoded.isEmpty) {
        return _generateInitialProgress();
      }

      return decoded
          .map((e) => LevelProgress.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      return _generateInitialProgress();
    }
  }

  Future<void> saveLevelProgress(List<LevelProgress> progress) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = progress.map((p) => p.toJson()).toList();
    await prefs.setString(_progressKey, jsonEncode(encoded));
  }

  Future<int> getCurrentLevel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_currentLevelKey) ?? 1;
  }

  Future<void> setCurrentLevel(int level) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_currentLevelKey, level);
  }

  Future<int> getCoins() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_coinsKey) ?? 566;
  }

  Future<void> setCoins(int coins) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_coinsKey, coins);
  }

  Future<void> updateLevelCompletion(
    int levelNumber,
    int stars,
    int score,
  ) async {
    final progress = await loadLevelProgress();
    final index = levelNumber - 1;
    
    if (index >= 0 && index < progress.length) {
      final current = progress[index];
      final updated = current.copyWith(
        isCompleted: true,
        stars: stars > current.stars ? stars : current.stars,
        bestScore: current.bestScore == null || score > current.bestScore!
            ? score
            : current.bestScore,
      );
      
      progress[index] = updated;
      
      // Unlock next level
      if (index + 1 < progress.length) {
        progress[index + 1] = progress[index + 1].copyWith(isUnlocked: true);
      }
      
      await saveLevelProgress(progress);
    }
  }

  List<LevelProgress> _generateInitialProgress() {
    const totalLevels = 500;
    final progress = <LevelProgress>[];
    
    for (int i = 1; i <= totalLevels; i++) {
      final difficulty = _getDifficultyForLevel(i);
      progress.add(LevelProgress(
        levelNumber: i,
        isUnlocked: true, // TODO: revert to `i == 1` when testing is done
        isCompleted: false,
        stars: 0,
        difficulty: difficulty,
      ));
    }
    
    return progress;
  }

  PuzzleDifficulty _getDifficultyForLevel(int level) {
    if (level <= 10) return PuzzleDifficulty.easy;
    if (level <= 25) return PuzzleDifficulty.easyMedium;
    if (level <= 50) return PuzzleDifficulty.medium;
    if (level <= 100) return PuzzleDifficulty.mediumHard;
    if (level <= 250) return PuzzleDifficulty.hard;
    return PuzzleDifficulty.expert;
  }
}