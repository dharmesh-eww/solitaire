import 'package:flutter/material.dart';
import 'package:statekit/statekit.dart';

import '../../../core/constants/game_colors.dart';
import '../../../routes/app_routes.dart';
import '../../play_screen/view/widgets/game_table_background.dart';
import '../binding/home_screen_binding.dart';
import '../controller/home_screen_controller.dart';

// ignore: must_be_immutable
class HomeScreen extends StatekitView<HomeScreenController>
    implements HomeScreenBinding {
  HomeScreen({super.key, super.tag});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameTableBackground(
        child: SafeArea(
          child: StateBuilder<HomeScreenController>(
            controller: controller,
            builder: (context, controller, child) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final compact = constraints.maxHeight < 720;

                  return SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          22,
                          compact ? 18 : 28,
                          22,
                          18,
                        ),
                        child: Column(
                          children: [
                            _HomeHeader(width: width, onLevelsTap: controller.onLevelsTap),
                            SizedBox(height: compact ? 18 : 30),
                            _CardQuestLogo(compact: compact),
                            SizedBox(height: compact ? 18 : 28),
                            _PreviewTableau(maxWidth: width),
                            SizedBox(height: compact ? 20 : 34),
                            _PlayButton(onTap: controller.onPlayTap),
                            const SizedBox(height: 14),
                            const _MetaStrip(),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  void onPlayPressed() {
    Navigator.pushNamed(context, Routes.playScreen);
  }

  @override
  void onLevelsPressed() {
    Navigator.pushNamed(context, Routes.levelSelection);
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.width, required this.onLevelsTap});

  final double width;
  final VoidCallback onLevelsTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _RoundControl(icon: Icons.settings_rounded, onTap: () {}),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: GameColors.headerBar.withValues(alpha: 0.84),
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
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.monetization_on_rounded,
                color: GameColors.coinGold,
                size: 24,
              ),
              SizedBox(width: 7),
              Text(
                '566',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
              SizedBox(width: 8),
              _PlusDot(),
            ],
          ),
        ),
        const SizedBox(width: 8),
        _RoundControl(icon: Icons.map_rounded, onTap: onLevelsTap),
      ],
    );
  }
}

class _CardQuestLogo extends StatelessWidget {
  const _CardQuestLogo({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: compact ? 120 : 144,
          height: compact ? 100 : 120,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                left: 18,
                top: 18,
                child: Transform.rotate(
                  angle: -0.16,
                  child: const _LogoCard(text: 'Word'),
                ),
              ),
              Positioned(
                right: 18,
                top: 12,
                child: Transform.rotate(
                  angle: 0.14,
                  child: const _LogoCard(text: 'Quest', blue: true),
                ),
              ),
              Positioned(
                bottom: 4,
                child: Container(
                  width: compact ? 58 : 68,
                  height: compact ? 58 : 68,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        GameColors.categoryHeader,
                        GameColors.categoryHeaderDark,
                      ],
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFFFF0A6),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.32),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.workspace_premium_rounded,
                    color: const Color(0xFF5A3200),
                    size: compact ? 34 : 40,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'CardQuest',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 40,
            fontWeight: FontWeight.w900,
            height: 1,
            shadows: [
              Shadow(
                color: Color(0x99000000),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
        ),
        const SizedBox(height: 7),
        Text(
          'Word Association Solitaire',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _PreviewTableau extends StatelessWidget {
  const _PreviewTableau({required this.maxWidth});

  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final cardWidth = (maxWidth * 0.22).clamp(72.0, 92.0);

    return SizedBox(
      height: cardWidth * 2.1,
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 10,
            left: 8,
            child: _PreviewStack(
              title: 'Museum',
              words: const ['Display', 'Gallery'],
              width: cardWidth,
            ),
          ),
          Positioned(
            top: 0,
            child: _PreviewStack(
              title: 'Seasons',
              words: const ['Winter', 'Autumn'],
              width: cardWidth,
              active: true,
            ),
          ),
          Positioned(
            top: 10,
            right: 8,
            child: _PreviewStack(
              title: 'Writer',
              words: const ['Twain', 'Dickens'],
              width: cardWidth,
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewStack extends StatelessWidget {
  const _PreviewStack({
    required this.title,
    required this.words,
    required this.width,
    this.active = false,
  });

  final String title;
  final List<String> words;
  final double width;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: width * 1.86,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _CategoryPill(title: title, active: active),
          ),
          for (var i = 0; i < words.length; i++)
            Positioned(
              top: 34 + i * width * 0.42,
              left: 0,
              right: 0,
              child: _MiniCard(
                text: words[i],
                width: width,
                highlighted: active && i == words.length - 1,
              ),
            ),
        ],
      ),
    );
  }
}

class _PlayButton extends StatefulWidget {
  const _PlayButton({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_PlayButton> createState() => _PlayButtonState();
}

class _PlayButtonState extends State<_PlayButton> {
  bool pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => pressed = true),
      onTapCancel: () => setState(() => pressed = false),
      onTapUp: (_) {
        setState(() => pressed = false);
        widget.onTap();
      },
      child: AnimatedScale(
        scale: pressed ? 0.96 : 1,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOut,
        child: Container(
          width: MediaQuery.sizeOf(context).width * 0.72,
          height: 64,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFFC343), GameColors.shuffleOrange],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFFFE08A), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: pressed ? 0.22 : 0.34),
                blurRadius: pressed ? 6 : 12,
                offset: Offset(0, pressed ? 3 : 7),
              ),
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.play_arrow_rounded, color: Colors.white, size: 34),
              SizedBox(width: 8),
              Text(
                'Play',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 26,
                  shadows: [
                    Shadow(
                      color: Color(0x77000000),
                      blurRadius: 3,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaStrip extends StatelessWidget {
  const _MetaStrip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: GameColors.instructionBar,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.offline_bolt_rounded, color: GameColors.categoryHeader),
          SizedBox(width: 8),
          Text(
            'Offline puzzles',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundControl extends StatelessWidget {
  const _RoundControl({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
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
        child: Icon(icon, color: Colors.white, size: 26),
      ),
    );
  }
}

class _LogoCard extends StatelessWidget {
  const _LogoCard({required this.text, this.blue = false});

  final String text;
  final bool blue;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 62,
      height: 86,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: blue ? GameColors.cardBack : GameColors.cardFace,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: blue ? const Color(0xFF7FB6FF) : GameColors.cardBorder,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 8,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: blue ? Colors.white : const Color(0xFF3A210C),
          fontSize: 13,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _MiniCard extends StatelessWidget {
  const _MiniCard({
    required this.text,
    required this.width,
    this.highlighted = false,
  });

  final String text;
  final double width;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: width * 1.18,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: GameColors.cardFace,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: highlighted
              ? GameColors.categoryActiveBorder
              : GameColors.cardBorder,
          width: highlighted ? 2.4 : 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: highlighted ? 12 : 7,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: const Color(0xFF3A210C),
          fontWeight: FontWeight.w900,
          fontSize: width * 0.16,
        ),
      ),
    );
  }
}

class _CategoryPill extends StatelessWidget {
  const _CategoryPill({required this.title, required this.active});

  final String title;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [GameColors.categoryHeader, GameColors.categoryHeaderDark],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: active
              ? GameColors.categoryActiveBorder
              : const Color(0xFFFFF0A6),
          width: active ? 2 : 1.2,
        ),
      ),
      child: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Color(0xFF3A210C),
          fontWeight: FontWeight.w900,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _PlusDot extends StatelessWidget {
  const _PlusDot();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: GameColors.movesRibbon,
        shape: BoxShape.circle,
      ),
      child: SizedBox(
        width: 22,
        height: 22,
        child: Icon(Icons.add, color: Colors.white, size: 16),
      ),
    );
  }
}
