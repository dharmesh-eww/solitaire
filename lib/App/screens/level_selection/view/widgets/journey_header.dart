import 'package:flutter/material.dart';
import '../../../../core/constants/game_colors.dart';

class JourneyHeader extends StatelessWidget {
  const JourneyHeader({
    super.key,
    required this.coins,
    required this.onBack,
    required this.onSettings,
  });

  final int coins;
  final VoidCallback onBack;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          _CircleIconButton(
            icon: Icons.arrow_back_rounded,
            onTap: onBack,
          ),
          const SizedBox(width: 8),
          const Text(
            'JOURNEY',
            style: TextStyle(
              color: GameColors.textLight,
              fontWeight: FontWeight.w800,
              fontSize: 20,
              letterSpacing: 1.2,
            ),
          ),
          const Spacer(),
          _CoinBadge(coins: coins),
          const SizedBox(width: 8),
          _CircleIconButton(
            icon: Icons.settings_rounded,
            onTap: onSettings,
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
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: GameColors.headerIconBg,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.28),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 22),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: GameColors.headerBar.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.24),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.monetization_on_rounded,
            color: GameColors.coinGold,
            size: 22,
          ),
          const SizedBox(width: 6),
          Text(
            '$coins',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}