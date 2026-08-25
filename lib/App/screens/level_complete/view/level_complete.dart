import 'package:flutter/material.dart';
import 'package:statekit/statekit.dart';

import '../../../core/constants/game_colors.dart';
import '../../../routes/app_routes.dart';
import '../../play_screen/controller/play_screen_controller.dart';
import '../../play_screen/view/play_screen.dart';
import '../../play_screen/view/widgets/game_table_background.dart';
import '../binding/level_complete_binding.dart';
import '../controller/level_complete_controller.dart';
import 'widgets/animated_star_rating.dart';
import 'widgets/confetti_particles.dart';
import 'widgets/level_stats_card.dart';
import 'widgets/sunburst_rays.dart';
import 'widgets/unity_game_button.dart';
import 'widgets/victory_ribbon.dart';

class LevelComplete extends StatekitView<LevelCompleteController>
    implements LevelCompleteBinding {
  LevelComplete({super.key, super.tag});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameTableBackground(
        child: Stack(
          children: [
            // Ambient Rotating Sunburst Rays
            const Center(
              child: SunburstRays(size: 600),
            ),

            // Ambient Celebration Confetti and Star Sparkles
            const Positioned.fill(
              child: ConfettiParticles(),
            ),

            // Main Content Area with Entrance Sequence
            SafeArea(
              child: StateBuilder<LevelCompleteController>(
                controller: controller,
                builder: (context, controller, child) {
                  final data = controller.data;

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final maxHeight = constraints.maxHeight;
                      final maxWidth = constraints.maxWidth;
                      final isCompact = maxHeight < 700;

                      return SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minHeight: maxHeight),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(height: isCompact ? 10 : 20),

                                // Victory Ribbon Banner (Unity 3D Style)
                                VictoryRibbon(
                                  title: data.stars >= 3
                                      ? 'VICTORY!'
                                      : 'LEVEL COMPLETE!',
                                  levelNumber: data.levelNumber,
                                ),
                                const SizedBox(height: 12),

                                // Animated 3-Star Celebration Arc
                                AnimatedStarRating(
                                  stars: data.stars,
                                  startDelay: const Duration(milliseconds: 350),
                                ),
                                const SizedBox(height: 12),

                                // Main Stats & Score Parchment Plaque
                                ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth: (maxWidth * 0.9).clamp(280.0, 420.0),
                                  ),
                                  child: LevelStatsCard(
                                    data: data,
                                    startDelay: const Duration(milliseconds: 700),
                                  ),
                                ),
                                SizedBox(height: isCompact ? 20 : 30),

                                // Big Juicy "NEXT LEVEL ▶" Primary Button
                                ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth: (maxWidth * 0.85).clamp(260.0, 380.0),
                                  ),
                                  child: UnityGameButton(
                                    onTap: controller.onNextLevelTap,
                                    height: 62,
                                    isPulsing: true,
                                    primaryColor: const Color(0xFF43A047),
                                    secondaryColor: const Color(0xFF1B5E20),
                                    bevelColor: const Color(0xFF0D3813),
                                    borderColor: const Color(0xFFB9F6CA),
                                    child: const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'NEXT LEVEL',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 1.6,
                                            shadows: [
                                              Shadow(
                                                color: Color(0xFF003300),
                                                blurRadius: 4,
                                                offset: Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Icon(
                                          Icons.play_arrow_rounded,
                                          color: Colors.white,
                                          size: 28,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 18),

                                // Secondary Actions Bar: Home, Replay, Levels Map
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Home Button
                                    UnityIconButton(
                                      icon: Icons.home_rounded,
                                      size: 50,
                                      onTap: controller.onHomeTap,
                                      primaryColor: const Color(0xFF546E7A),
                                      secondaryColor: const Color(0xFF37474F),
                                      bevelColor: const Color(0xFF1C2833),
                                      borderColor: const Color(0xFFB0BEC5),
                                    ),
                                    const SizedBox(width: 16),

                                    // Replay / Retry Button
                                    UnityIconButton(
                                      icon: Icons.replay_rounded,
                                      size: 50,
                                      onTap: controller.onReplayTap,
                                      primaryColor: const Color(0xFFFB8C00),
                                      secondaryColor: const Color(0xFFE65100),
                                      bevelColor: const Color(0xFF8A3000),
                                      borderColor: const Color(0xFFFFCC80),
                                    ),
                                    const SizedBox(width: 16),

                                    // Levels Map Button
                                    UnityIconButton(
                                      icon: Icons.map_rounded,
                                      size: 50,
                                      onTap: controller.onLevelsTap,
                                      primaryColor: const Color(0xFF1E88E5),
                                      secondaryColor: const Color(0xFF0D47A1),
                                      bevelColor: const Color(0xFF072659),
                                      borderColor: const Color(0xFF90CAF9),
                                    ),
                                  ],
                                ),
                                SizedBox(height: isCompact ? 10 : 20),
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
          ],
        ),
      ),
    );
  }

  @override
  void onNextLevel(int nextLevel) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        settings: RouteSettings(name: Routes.playScreen, arguments: nextLevel),
        pageBuilder: (context, animation, secondaryAnimation) => StateProvider(
          stateProvider: StatekitProvider(
            create: () => PlayScreenController(level: nextLevel),
          ),
          child: PlayScreen(),
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.9, end: 1.0).animate(curved),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 550),
      ),
    );
  }

  @override
  void onReplayLevel(int levelNumber) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        settings: RouteSettings(name: Routes.playScreen, arguments: levelNumber),
        pageBuilder: (context, animation, secondaryAnimation) => StateProvider(
          stateProvider: StatekitProvider(
            create: () => PlayScreenController(level: levelNumber),
          ),
          child: PlayScreen(),
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.9, end: 1.0).animate(curved),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 550),
      ),
    );
  }

  @override
  void onLevelsPressed() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      Routes.levelSelection,
      (route) => route.isFirst,
    );
  }

  @override
  void onHomePressed() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      Routes.homeScreen,
      (route) => false,
    );
  }
}
