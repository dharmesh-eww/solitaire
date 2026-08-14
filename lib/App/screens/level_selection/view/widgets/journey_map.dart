import 'package:flutter/material.dart';
import '../../../../core/constants/game_colors.dart';
import '../../controller/level_selection_controller.dart';
import 'journey_background.dart';
import 'level_node.dart';

class JourneyMap extends StatefulWidget {
  const JourneyMap({
    super.key,
    required this.controller,
  });

  final LevelSelectionController controller;

  @override
  State<JourneyMap> createState() => _JourneyMapState();
}

class _JourneyMapState extends State<JourneyMap>
    with SingleTickerProviderStateMixin {
  late AnimationController _entranceController;
  late Animation<double> _entranceAnimation;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    
    _entranceAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOutCubic),
    );
    
    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const JourneyBackground(),
        CustomScrollView(
          controller: widget.controller.scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index >= widget.controller.levelProgress.length) return const SizedBox.shrink();
                    
                    final progress = widget.controller.levelProgress[index];
                    final isCurrent = progress.levelNumber == widget.controller.currentLevel;
                    
                    return AnimatedBuilder(
                      animation: _entranceAnimation,
                      builder: (context, child) {
                        final delay = (index * 0.05).clamp(0.0, 0.8);
                        final animationValue = ((_entranceAnimation.value - delay) / (1 - delay)).clamp(0.0, 1.0);
                        
                        return FadeSlideIn(
                          visible: animationValue > 0,
                          offset: 1 - animationValue,
                          child: child ?? const SizedBox.shrink(),
                        );
                      },
                      child: Column(
                        children: [
                          LevelNode(
                            progress: progress,
                            isCurrent: isCurrent,
                            onTap: () => widget.controller.onLevelTap(progress.levelNumber),
                            controller: widget.controller,
                          ),
                          if (index < widget.controller.levelProgress.length - 1)
                            _PathConnector(
                              isCompleted: progress.isCompleted,
                              isNextCurrent: widget.controller.levelProgress[index + 1].levelNumber == widget.controller.currentLevel,
                            ),
                        ],
                      ),
                    );
                  },
                  childCount: widget.controller.levelProgress.length,
                ),
              ),
            ),
          ],
        ),
        // Jump to current level button
        Positioned(
          right: 16,
          bottom: 16,
          child: _JumpToCurrentButton(
            currentLevel: widget.controller.currentLevel,
            onTap: () => widget.controller.scrollToCurrentLevel(),
          ),
        ),
      ],
    );
  }
}

class FadeSlideIn extends StatelessWidget {
  const FadeSlideIn({
    super.key,
    required this.visible,
    required this.offset,
    required this.child,
  });

  final bool visible;
  final double offset;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: visible ? 1.0 : 0.0,
      child: Transform.translate(
        offset: Offset(0, visible ? offset * 30 : 30),
        child: child,
      ),
    );
  }
}

class _PathConnector extends StatelessWidget {
  const _PathConnector({
    required this.isCompleted,
    required this.isNextCurrent,
  });

  final bool isCompleted;
  final bool isNextCurrent;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      width: 4,
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isCompleted || isNextCurrent
              ? const [
                  GameColors.categoryHeader,
                  GameColors.categoryHeaderDark,
                ]
              : [
                  GameColors.starEmpty.withValues(alpha: 0.4),
                  GameColors.starEmpty.withValues(alpha: 0.2),
                ],
        ),
        borderRadius: BorderRadius.circular(2),
        boxShadow: isCompleted || isNextCurrent
            ? [
                BoxShadow(
                  color: GameColors.categoryHeader.withValues(alpha: 0.3),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
    );
  }
}

class _JumpToCurrentButton extends StatelessWidget {
  const _JumpToCurrentButton({
    required this.currentLevel,
    required this.onTap,
  });

  final int currentLevel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: <Color>[GameColors.categoryHeader, GameColors.categoryHeaderDark],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFFFFF0A6),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.arrow_downward_rounded,
              color: Color(0xFF3A210C),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Level $currentLevel',
              style: const TextStyle(
                color: Color(0xFF3A210C),
                fontWeight: FontWeight.w900,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}