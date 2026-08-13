import 'dart:math';

import 'package:flutter/material.dart';
import '../constants/color_constants.dart';

class GameBackground extends StatelessWidget {
  const GameBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.backgroundColor,
            AppColors.backgroundGradientEnd,
          ],
        ),
      ),
      child: Stack(
        children: [
          const _DecorativePattern(),
          child,
        ],
      ),
    );
  }
}

class _DecorativePattern extends StatelessWidget {
  const _DecorativePattern();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: size.height * 0.08,
            left: -24,
            child: _PuzzleTile(
              color: AppColors.puzzleAccentColors[0],
              size: 72,
              rotation: -0.15,
            ),
          ),
          Positioned(
            top: size.height * 0.14,
            right: -16,
            child: _PuzzleTile(
              color: AppColors.puzzleAccentColors[2],
              size: 56,
              rotation: 0.2,
            ),
          ),
          Positioned(
            top: size.height * 0.32,
            left: size.width * 0.06,
            child: _PuzzleTile(
              color: AppColors.puzzleAccentColors[4],
              size: 40,
              rotation: 0.35,
              opacity: 0.35,
            ),
          ),
          Positioned(
            top: size.height * 0.55,
            right: size.width * 0.08,
            child: _PuzzleTile(
              color: AppColors.puzzleAccentColors[3],
              size: 48,
              rotation: -0.25,
              opacity: 0.3,
            ),
          ),
          Positioned(
            bottom: size.height * 0.12,
            left: size.width * 0.1,
            child: _PuzzleTile(
              color: AppColors.puzzleAccentColors[1],
              size: 64,
              rotation: 0.1,
              opacity: 0.28,
            ),
          ),
          Positioned(
            bottom: size.height * 0.18,
            right: size.width * 0.12,
            child: _PuzzleTile(
              color: AppColors.puzzleAccentColors[5],
              size: 52,
              rotation: -0.3,
              opacity: 0.32,
            ),
          ),
          Positioned(
            top: size.height * 0.42,
            right: size.width * 0.22,
            child: _ColorDot(
              color: AppColors.puzzleAccentColors[0],
              size: 14,
            ),
          ),
          Positioned(
            top: size.height * 0.68,
            left: size.width * 0.18,
            child: _ColorDot(
              color: AppColors.puzzleAccentColors[2],
              size: 10,
            ),
          ),
          Positioned(
            bottom: size.height * 0.32,
            right: size.width * 0.28,
            child: _ColorDot(
              color: AppColors.puzzleAccentColors[1],
              size: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _PuzzleTile extends StatelessWidget {
  const _PuzzleTile({
    required this.color,
    required this.size,
    this.rotation = 0,
    this.opacity = 0.45,
  });

  final Color color;
  final double size;
  final double rotation;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color.withValues(alpha: opacity),
          borderRadius: BorderRadius.circular(size * 0.22),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: opacity * 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  const _ColorDot({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.35),
      ),
    );
  }
}

class GameLogoMark extends StatelessWidget {
  const GameLogoMark({super.key, this.size = 88});

  final double size;

  @override
  Widget build(BuildContext context) {
    final tileSize = size * 0.42;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.rotate(
            angle: -pi / 10,
            child: _LogoTile(
              color: AppColors.puzzleAccentColors[0],
              size: tileSize,
              offset: Offset(-tileSize * 0.28, -tileSize * 0.18),
            ),
          ),
          Transform.rotate(
            angle: pi / 12,
            child: _LogoTile(
              color: AppColors.puzzleAccentColors[2],
              size: tileSize,
              offset: Offset(tileSize * 0.24, -tileSize * 0.22),
            ),
          ),
          Transform.rotate(
            angle: -pi / 14,
            child: _LogoTile(
              color: AppColors.puzzleAccentColors[1],
              size: tileSize,
              offset: Offset(-tileSize * 0.1, tileSize * 0.2),
            ),
          ),
          Container(
            width: tileSize * 0.72,
            height: tileSize * 0.72,
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.circular(tileSize * 0.18),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryDark.withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(
              Icons.extension_rounded,
              color: Colors.white,
              size: tileSize * 0.42,
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoTile extends StatelessWidget {
  const _LogoTile({
    required this.color,
    required this.size,
    required this.offset,
  });

  final Color color;
  final double size;
  final Offset offset;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: offset,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(size * 0.22),
        ),
      ),
    );
  }
}
