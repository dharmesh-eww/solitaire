import 'package:flutter/material.dart';
import '../../../../core/constants/game_colors.dart';

class StarDisplay extends StatelessWidget {
  const StarDisplay({
    super.key,
    required this.stars,
  });

  final int stars; // 0-3

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          3,
          (index) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Icon(
              index < stars ? Icons.star_rounded : Icons.star_border_rounded,
              color: index < stars ? GameColors.coinGold : GameColors.starEmpty,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}