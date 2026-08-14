import 'package:flutter/material.dart';
import '../../../../core/constants/game_colors.dart';
import '../../controller/level_selection_controller.dart';
import '../../model/level_progress.dart';
import 'star_display.dart';
import 'level_preview_sheet.dart';

class LevelNode extends StatefulWidget {
  const LevelNode({
    super.key,
    required this.progress,
    required this.isCurrent,
    required this.onTap,
    required this.controller,
  });

  final LevelProgress progress;
  final bool isCurrent;
  final VoidCallback onTap;
  final LevelSelectionController controller;

  @override
  State<LevelNode> createState() => _LevelNodeState();
}

class _LevelNodeState extends State<LevelNode>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    if (widget.isCurrent) {
      _pulseController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1500),
      )..repeat(reverse: true);
      
      _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
        CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
      );
    }
  }

  @override
  void dispose() {
    if (widget.isCurrent) {
      _pulseController.dispose();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(LevelNode oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCurrent && !oldWidget.isCurrent) {
      _pulseController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1500),
      )..repeat(reverse: true);
      
      _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
        CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
      );
    } else if (!widget.isCurrent && oldWidget.isCurrent) {
      _pulseController.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.progress.isUnlocked
          ? (_) => setState(() => _isPressed = true)
          : null,
      onTapUp: widget.progress.isUnlocked
          ? (_) {
              setState(() => _isPressed = false);
              
              if (widget.isCurrent) {
                widget.onTap();
              } else if (widget.progress.isCompleted) {
                LevelPreviewSheet.show(
                  context,
                  progress: widget.progress,
                  controller: widget.controller,
                );
              } else {
                widget.onTap();
              }
            }
          : null,
      onTapCancel: widget.progress.isUnlocked
          ? () => setState(() => _isPressed = false)
          : null,
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : (widget.isCurrent ? _pulseAnimation.value : 1.0),
        duration: const Duration(milliseconds: 100),
        child: widget.progress.isUnlocked
            ? _UnlockedNode(
                progress: widget.progress,
                isCurrent: widget.isCurrent,
              )
            : _LockedNode(progress: widget.progress),
      ),
    );
  }
}

class _UnlockedNode extends StatelessWidget {
  const _UnlockedNode({
    required this.progress,
    required this.isCurrent,
  });

  final LevelProgress progress;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final nodeSize = isCurrent ? 100.0 : 80.0;
    
    return Column(
      children: [
        if (progress.isCompleted)
          StarDisplay(stars: progress.stars),
        if (!progress.isCompleted && !isCurrent)
          const SizedBox(height: 24),
        Container(
          width: nodeSize,
          height: nodeSize,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [GameColors.tableBackground, GameColors.tableBackgroundDark],
            ),
            shape: BoxShape.circle,
            border: Border.all(
              color: isCurrent
                  ? GameColors.categoryHeader
                  : GameColors.coinGold,
              width: isCurrent ? 4 : 3,
            ),
            boxShadow: [
              BoxShadow(
                color: isCurrent
                    ? GameColors.categoryHeader.withValues(alpha: 0.5)
                    : Colors.black.withValues(alpha: 0.3),
                blurRadius: isCurrent ? 20 : 12,
                spreadRadius: isCurrent ? 2 : 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (isCurrent)
                Positioned(
                  top: -8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [GameColors.categoryHeader, GameColors.categoryHeaderDark],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFFFF0A6),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Text(
                      'CURRENT',
                      style: TextStyle(
                        color: Color(0xFF3A210C),
                        fontWeight: FontWeight.w900,
                        fontSize: 10,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              Text(
                '${progress.levelNumber}',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: isCurrent ? 32 : 26,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
              if (isCurrent)
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: GameColors.crownGold,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.star_rounded,
                      color: Color(0xFF5A3200),
                      size: 14,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Level ${progress.levelNumber}',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: isCurrent ? 16 : 14,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LockedNode extends StatelessWidget {
  const _LockedNode({required this.progress});

  final LevelProgress progress;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 24),
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: GameColors.starEmpty.withValues(alpha: 0.3),
            shape: BoxShape.circle,
            border: Border.all(
              color: GameColors.starEmpty.withValues(alpha: 0.5),
              width: 2,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Opacity(
                opacity: 0.5,
                child: Text(
                  '${progress.levelNumber}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                ),
              ),
              const Positioned(
                bottom: 6,
                child: Icon(
                  Icons.lock_rounded,
                  color: GameColors.starEmpty,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Opacity(
          opacity: 0.6,
          child: Text(
            'Level ${progress.levelNumber}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}