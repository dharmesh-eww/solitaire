import 'package:flutter/material.dart';
import '../../../../core/constants/game_colors.dart';
import '../../model/level_complete_data.dart';

class LevelStatsCard extends StatefulWidget {
  const LevelStatsCard({
    super.key,
    required this.data,
    this.startDelay = const Duration(milliseconds: 600),
  });

  final LevelCompleteData data;
  final Duration startDelay;

  @override
  State<LevelStatsCard> createState() => _LevelStatsCardState();
}

class _LevelStatsCardState extends State<LevelStatsCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _countController;
  late final Animation<double> _countAnimation;

  @override
  void initState() {
    super.initState();
    _countController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _countAnimation = CurvedAnimation(
      parent: _countController,
      curve: Curves.easeOutCubic,
    );

    Future.delayed(widget.startDelay, () {
      if (mounted) {
        _countController.forward();
      }
    });
  }

  @override
  void dispose() {
    _countController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _countAnimation,
      builder: (context, child) {
        final progress = _countAnimation.value;
        final currentScore = (widget.data.score * progress).round();
        final currentCoins = (widget.data.coinsReward * progress).round();

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFCF8EC),
                Color(0xFFF3EBCE),
              ],
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: const Color(0xFFFFD54F),
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
              const BoxShadow(
                color: Color(0xFFC79E35),
                blurRadius: 0,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Performance Title Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1B5E20).withValues(alpha: 0.4),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  widget.data.performanceTitle,
                  style: const TextStyle(
                    color: Color(0xFFE8F5E9),
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Score Counter Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFEADBBE).withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFD3BA8E).withValues(alpha: 0.8),
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      'TOTAL SCORE',
                      style: TextStyle(
                        color: Color(0xFF795548),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$currentScore',
                      style: const TextStyle(
                        color: Color(0xFF3E2723),
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Two Column Stats: Moves & Coins Reward
              Row(
                children: [
                  // Moves Left Stat
                  Expanded(
                    child: _StatPill(
                      icon: Icons.swap_vert_circle_rounded,
                      iconColor: GameColors.movesRibbon,
                      label: 'Moves Left',
                      value: '+${widget.data.movesRemaining}',
                      subtext: '${widget.data.movesUsed} used',
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Coins Reward Stat
                  Expanded(
                    child: _StatPill(
                      icon: Icons.monetization_on_rounded,
                      iconColor: GameColors.coinGold,
                      label: 'Reward',
                      value: '+$currentCoins',
                      subtext: 'Coins',
                      isHighlight: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.subtext,
    this.isHighlight = false,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String subtext;
  final bool isHighlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: isHighlight
            ? const Color(0xFFFFF8E1)
            : const Color(0xFFEADBBE).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isHighlight
              ? const Color(0xFFFFD54F)
              : const Color(0xFFD3BA8E).withValues(alpha: 0.6),
          width: isHighlight ? 1.8 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF8D6E63),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    color: isHighlight
                        ? const Color(0xFFE65100)
                        : const Color(0xFF3E2723),
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
