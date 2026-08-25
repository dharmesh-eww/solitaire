import 'package:flutter/material.dart';

class UnityGameButton extends StatefulWidget {
  const UnityGameButton({
    super.key,
    required this.onTap,
    required this.child,
    this.width,
    this.height = 58,
    this.primaryColor = const Color(0xFF4CAF50),
    this.secondaryColor = const Color(0xFF2E7D32),
    this.bevelColor = const Color(0xFF1B5E20),
    this.borderColor = const Color(0xFFA5D6A7),
    this.isPulsing = false,
  });

  final VoidCallback onTap;
  final Widget child;
  final double? width;
  final double height;
  final Color primaryColor;
  final Color secondaryColor;
  final Color bevelColor;
  final Color borderColor;
  final bool isPulsing;

  @override
  State<UnityGameButton> createState() => _UnityGameButtonState();
}

class _UnityGameButtonState extends State<UnityGameButton>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.isPulsing) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant UnityGameButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPulsing && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isPulsing && _pulseController.isAnimating) {
      _pulseController.stop();
      _pulseController.value = 0.0;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double bevelHeight = _isPressed ? 1.5 : 5.0;
    final double topMargin = _isPressed ? 3.5 : 0.0;

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        final scale = widget.isPulsing ? _pulseAnimation.value : 1.0;
        return Transform.scale(
          scale: _isPressed ? 0.96 : scale,
          child: GestureDetector(
            onTapDown: (_) => setState(() => _isPressed = true),
            onTapUp: (_) {
              setState(() => _isPressed = false);
              widget.onTap();
            },
            onTapCancel: () => setState(() => _isPressed = false),
            child: Container(
              width: widget.width,
              height: widget.height,
              margin: EdgeInsets.only(top: topMargin),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: _isPressed ? 0.2 : 0.35),
                    blurRadius: _isPressed ? 4 : 10,
                    offset: Offset(0, _isPressed ? 2 : 6),
                  ),
                  if (widget.isPulsing)
                    BoxShadow(
                      color: widget.primaryColor.withValues(alpha: 0.4),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                ],
              ),
              child: Stack(
                children: [
                  // 3D Bottom bevel
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: widget.bevelColor,
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                  // Button face
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    bottom: bevelHeight,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            widget.primaryColor,
                            widget.secondaryColor,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: widget.borderColor,
                          width: 2,
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Top glossy highlight reflection
                          Positioned(
                            top: 2,
                            left: 10,
                            right: 10,
                            height: (widget.height - bevelHeight) * 0.4,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.white.withValues(alpha: 0.45),
                                    Colors.white.withValues(alpha: 0.0),
                                  ],
                                ),
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          // Button content
                          widget.child,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class UnityIconButton extends StatefulWidget {
  const UnityIconButton({
    super.key,
    required this.onTap,
    required this.icon,
    this.size = 52,
    this.primaryColor = const Color(0xFF455A64),
    this.secondaryColor = const Color(0xFF263238),
    this.bevelColor = const Color(0xFF102027),
    this.borderColor = const Color(0xFF90A4AE),
  });

  final VoidCallback onTap;
  final IconData icon;
  final double size;
  final Color primaryColor;
  final Color secondaryColor;
  final Color bevelColor;
  final Color borderColor;

  @override
  State<UnityIconButton> createState() => _UnityIconButtonState();
}

class _UnityIconButtonState extends State<UnityIconButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final double bevelHeight = _isPressed ? 1.5 : 4.0;
    final double topMargin = _isPressed ? 2.5 : 0.0;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: Transform.scale(
        scale: _isPressed ? 0.94 : 1.0,
        child: Container(
          width: widget.size,
          height: widget.size,
          margin: EdgeInsets.only(top: topMargin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Bottom Bevel
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: widget.bevelColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              // Button Surface
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                bottom: bevelHeight,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [widget.primaryColor, widget.secondaryColor],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: widget.borderColor, width: 1.8),
                  ),
                  child: Icon(widget.icon, color: Colors.white, size: widget.size * 0.48),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
