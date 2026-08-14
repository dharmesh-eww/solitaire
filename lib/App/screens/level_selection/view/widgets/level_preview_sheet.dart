import 'package:flutter/material.dart';
import '../../../../core/constants/game_colors.dart';
import '../../../../core/puzzle/puzzle_difficulty.dart';
import '../../controller/level_selection_controller.dart';
import '../../model/level_progress.dart';

class LevelPreviewSheet extends StatelessWidget {
  const LevelPreviewSheet({
    super.key,
    required this.progress,
    required this.controller,
  });

  final LevelProgress progress;
  final LevelSelectionController controller;

  static Future<void> show(
    BuildContext context, {
    required LevelProgress progress,
    required LevelSelectionController controller,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => LevelPreviewSheet(
        progress: progress,
        controller: controller,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      margin: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: GameColors.cardFace,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: GameColors.cardBorder,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 48,
              height: 5,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: GameColors.cardBorder,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            // Level title
            Text(
              'LEVEL ${progress.levelNumber}',
              style: const TextStyle(
                color: Color(0xFF3A210C),
                fontWeight: FontWeight.w900,
                fontSize: 28,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            // Stars
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    index < progress.stars
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    color: index < progress.stars
                        ? GameColors.coinGold
                        : GameColors.starEmpty,
                    size: 32,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Stats row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatItem(
                  label: 'Difficulty',
                  value: _difficultyText(progress.difficulty),
                  icon: _difficultyIcon(progress.difficulty),
                ),
                _StatItem(
                  label: 'Groups',
                  value: '6',
                  icon: Icons.category_rounded,
                ),
                _StatItem(
                  label: 'Cards',
                  value: '24',
                  icon: Icons.style_rounded,
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Best score
            if (progress.bestScore != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: GameColors.tableBackground.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.emoji_events_rounded,
                      color: GameColors.crownGold,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Best Score: ${progress.bestScore}',
                      style: const TextStyle(
                        color: Color(0xFF3A210C),
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            if (progress.bestScore != null) const SizedBox(height: 24),
            // Play button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  controller.onPlayLevel(progress.levelNumber);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: GameColors.movesRibbon,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 8,
                  shadowColor: Colors.black.withValues(alpha: 0.3),
                ),
                child: const Text(
                  'PLAY LEVEL',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Cancel button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: GameColors.textDark.withValues(alpha: 0.6),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _difficultyText(PuzzleDifficulty difficulty) {
    switch (difficulty) {
      case PuzzleDifficulty.easy:
        return 'EASY';
      case PuzzleDifficulty.easyMedium:
        return 'EASY+';
      case PuzzleDifficulty.medium:
        return 'MEDIUM';
      case PuzzleDifficulty.mediumHard:
        return 'MEDIUM+';
      case PuzzleDifficulty.hard:
        return 'HARD';
      case PuzzleDifficulty.expert:
        return 'EXPERT';
    }
  }

  IconData _difficultyIcon(PuzzleDifficulty difficulty) {
    switch (difficulty) {
      case PuzzleDifficulty.easy:
        return Icons.sentiment_satisfied_rounded;
      case PuzzleDifficulty.easyMedium:
        return Icons.sentiment_satisfied_rounded;
      case PuzzleDifficulty.medium:
        return Icons.sentiment_neutral_rounded;
      case PuzzleDifficulty.mediumHard:
        return Icons.sentiment_dissatisfied_rounded;
      case PuzzleDifficulty.hard:
        return Icons.sentiment_dissatisfied_rounded;
      case PuzzleDifficulty.expert:
        return Icons.local_fire_department_rounded;
    }
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: GameColors.headerIconBg.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: GameColors.headerIconBg,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF3A210C),
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: GameColors.textDark.withValues(alpha: 0.5),
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}