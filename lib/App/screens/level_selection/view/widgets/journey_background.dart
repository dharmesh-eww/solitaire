import 'package:flutter/material.dart';
import '../../../../core/constants/game_colors.dart';

class JourneyBackground extends StatelessWidget {
  const JourneyBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Subtle gradient overlay
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                GameColors.tableBackground.withValues(alpha: 0.3),
                GameColors.tableBackgroundDark.withValues(alpha: 0.5),
              ],
            ),
          ),
        ),
        // Decorative elements
        Positioned(
          top: 100,
          left: -50,
          child: _DecorativeCircle(size: 150, opacity: 0.1),
        ),
        Positioned(
          top: 300,
          right: -80,
          child: _DecorativeCircle(size: 200, opacity: 0.08),
        ),
        Positioned(
          bottom: 200,
          left: -60,
          child: _DecorativeCircle(size: 180, opacity: 0.1),
        ),
      ],
    );
  }
}

class _DecorativeCircle extends StatelessWidget {
  const _DecorativeCircle({
    required this.size,
    required this.opacity,
  });

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: GameColors.categoryHeader.withValues(alpha: opacity),
      ),
    );
  }
}