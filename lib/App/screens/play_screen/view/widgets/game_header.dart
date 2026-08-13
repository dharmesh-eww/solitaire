import 'package:flutter/material.dart';
import '../../../../core/constants/game_colors.dart';

class GameHeader extends StatelessWidget {
  const GameHeader({
    super.key,
    required this.level,
    required this.hintCount,
    required this.undoCount,
    required this.onPause,
    required this.onHint,
    required this.onUndo,
    required this.onMenu,
    this.coins = 566,
  });

  final int level;
  final int hintCount;
  final int undoCount;
  final int coins;
  final VoidCallback onPause;
  final VoidCallback onHint;
  final VoidCallback onUndo;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          _CircleIconButton(
            icon: Icons.pause_rounded,
            onTap: onPause,
          ),
          const SizedBox(width: 6),
          _CoinBadge(coins: coins),
          const Spacer(),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Level $level',
                style: const TextStyle(
                  color: GameColors.textLight,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  3,
                  (_) => const Icon(
                    Icons.star_border_rounded,
                    color: GameColors.starEmpty,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          _BadgeIconButton(
            icon: Icons.lightbulb_rounded,
            badge: hintCount,
            onTap: onHint,
          ),
          const SizedBox(width: 6),
          _BadgeIconButton(
            icon: Icons.undo_rounded,
            badge: undoCount,
            onTap: onUndo,
          ),
          const SizedBox(width: 6),
          _CircleIconButton(
            icon: Icons.menu_rounded,
            onTap: onMenu,
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: GameColors.headerIconBg,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: GameColors.textLight, size: 20),
      ),
    );
  }
}

class _BadgeIconButton extends StatelessWidget {
  const _BadgeIconButton({
    required this.icon,
    required this.badge,
    required this.onTap,
  });

  final IconData icon;
  final int badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          _CircleIconButton(icon: icon, onTap: onTap),
          if (badge > 0)
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: GameColors.badgeRed,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$badge',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CoinBadge extends StatelessWidget {
  const _CoinBadge({required this.coins});

  final int coins;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: GameColors.headerBar.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.monetization_on_rounded,
            color: GameColors.coinGold,
            size: 20,
          ),
          const SizedBox(width: 4),
          Text(
            '$coins',
            style: const TextStyle(
              color: GameColors.textLight,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 4),
          Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              color: GameColors.movesRibbon,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 14),
          ),
        ],
      ),
    );
  }
}
