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
    this.starCount = 3,
  });

  final int level;
  final int hintCount;
  final int undoCount;
  final int coins;
  final int starCount;
  final VoidCallback onPause;
  final VoidCallback onHint;
  final VoidCallback onUndo;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Pause button
          _CircleIconButton(icon: Icons.pause_rounded, onTap: onPause),
          const SizedBox(width: 8),
          // Coin badge
          _CoinBadge(coins: coins),
          const Spacer(),
          // Level + stars
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Level $level',
                style: const TextStyle(
                  color: GameColors.textLight,
                  fontWeight: FontWeight.w900,
                  fontSize: 17,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 3),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  3,
                  (i) => Icon(
                    Icons.star_rounded,
                    color: i < starCount ? GameColors.starFilled : GameColors.starEmpty,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          // Hint
          _BadgeIconButton(
            icon: Icons.lightbulb_rounded,
            badge: hintCount,
            color: GameColors.hintBlue,
            onTap: onHint,
          ),
          const SizedBox(width: 6),
          // Undo
          _BadgeIconButton(
            icon: Icons.undo_rounded,
            badge: undoCount,
            color: GameColors.undoGrey,
            onTap: onUndo,
          ),
          const SizedBox(width: 6),
          // Menu
          _CircleIconButton(icon: Icons.menu_rounded, onTap: onMenu),
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
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: GameColors.headerIconBg,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.28),
              blurRadius: 5,
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
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final int badge;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.28),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          if (badge > 0)
            Positioned(
              top: -3,
              right: -3,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: GameColors.badgeRed,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white, width: 1.2),
                ),
                child: Text(
                  '$badge',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
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
      padding: const EdgeInsets.only(left: 4, right: 8, top: 4, bottom: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1A3D2B),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(
              color: GameColors.coinGold,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.workspace_premium_rounded,
              color: Color(0xFFBF7D00),
              size: 18,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '$coins',
            style: const TextStyle(
              color: GameColors.textLight,
              fontWeight: FontWeight.w800,
              fontSize: 14,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            width: 18,
            height: 18,
            decoration: const BoxDecoration(
              color: Color(0xFF2E7D32),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 12),
          ),
        ],
      ),
    );
  }
}
