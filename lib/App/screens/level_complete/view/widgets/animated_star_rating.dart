import 'package:flutter/material.dart';

class AnimatedStarRating extends StatefulWidget {
  const AnimatedStarRating({super.key, required this.stars, this.startDelay = const Duration(milliseconds: 300)});

  final int stars; // 1-3
  final Duration startDelay;

  @override
  State<AnimatedStarRating> createState() => _AnimatedStarRatingState();
}

class _AnimatedStarRatingState extends State<AnimatedStarRating> with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _scaleAnimations;
  late final List<Animation<double>> _rotationAnimations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      3,
      (i) => AnimationController(vsync: this, duration: const Duration(milliseconds: 600)),
    );

    _scaleAnimations = _controllers.map((c) {
      return TweenSequence<double>([
        TweenSequenceItem(
          tween: Tween<double>(begin: 0.0, end: 1.35).chain(CurveTween(curve: Curves.easeOutBack)),
          weight: 65,
        ),
        TweenSequenceItem(
          tween: Tween<double>(begin: 1.35, end: 1.0).chain(CurveTween(curve: Curves.easeInOut)),
          weight: 35,
        ),
      ]).animate(c);
    }).toList();

    _rotationAnimations = _controllers.map((c) {
      return Tween<double>(begin: -0.4, end: 0.0).chain(CurveTween(curve: Curves.easeOutBack)).animate(c);
    }).toList();

    _playSequence();
  }

  Future<void> _playSequence() async {
    await Future.delayed(widget.startDelay);
    for (var i = 0; i < 3; i++) {
      if (!mounted) return;
      if (i < widget.stars) {
        _controllers[i].forward();
        await Future.delayed(const Duration(milliseconds: 260));
      }
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      width: 260,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Left star (medium, rotated slightly left)
          Positioned(
            left: 20,
            bottom: 8,
            child: Transform.rotate(
              angle: -0.15,
              child: _StarSlot(
                index: 0,
                isEarned: widget.stars >= 1,
                size: 64,
                scaleAnimation: _scaleAnimations[0],
                rotationAnimation: _rotationAnimations[0],
              ),
            ),
          ),
          // Right star (medium, rotated slightly right)
          Positioned(
            right: 20,
            bottom: 8,
            child: Transform.rotate(
              angle: 0.15,
              child: _StarSlot(
                index: 2,
                isEarned: widget.stars >= 3,
                size: 64,
                scaleAnimation: _scaleAnimations[2],
                rotationAnimation: _rotationAnimations[2],
              ),
            ),
          ),
          // Center star (larger, elevated higher)
          Positioned(
            top: 0,
            child: _StarSlot(
              index: 1,
              isEarned: widget.stars >= 2,
              size: 84,
              scaleAnimation: _scaleAnimations[1],
              rotationAnimation: _rotationAnimations[1],
              isCenter: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _StarSlot extends StatelessWidget {
  const _StarSlot({
    required this.index,
    required this.isEarned,
    required this.size,
    required this.scaleAnimation,
    required this.rotationAnimation,
    this.isCenter = false,
  });

  final int index;
  final bool isEarned;
  final double size;
  final Animation<double> scaleAnimation;
  final Animation<double> rotationAnimation;
  final bool isCenter;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Empty background socket
          Icon(Icons.star_rounded, size: size, color: const Color(0xFF1E2822).withValues(alpha: 0.8)),
          Icon(Icons.star_outline_rounded, size: size, color: const Color(0xFFD4AF37).withValues(alpha: 0.3)),
          // Animated filled star
          if (isEarned)
            AnimatedBuilder(
              animation: scaleAnimation,
              builder: (context, child) {
                if (scaleAnimation.value <= 0.01) {
                  return const SizedBox.shrink();
                }
                return Transform.scale(
                  scale: scaleAnimation.value,
                  child: Transform.rotate(
                    angle: rotationAnimation.value,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Star glow flare
                        Container(
                          width: size * 0.9,
                          height: size * 0.9,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFFD54F).withValues(alpha: 0.65),
                                blurRadius: 20,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                        ),
                        // 3D Star icon with multi-layered gradient
                        ShaderMask(
                          shaderCallback: (bounds) {
                            return const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0xFFFFFDE7), Color(0xFFFFEB3B), Color(0xFFFFB300), Color(0xFFFF8F00)],
                              stops: [0.0, 0.35, 0.7, 1.0],
                            ).createShader(bounds);
                          },
                          child: Icon(Icons.star_rounded, size: size, color: Colors.white),
                        ),
                        // Outer crisp golden bevel border
                        Icon(Icons.star_outline_rounded, size: size, color: const Color(0xFFFFF9C4)),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
