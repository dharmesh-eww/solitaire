import 'package:statekit/statekit.dart';
import 'package:flutter/material.dart';
import '../../../core/utils/app_text_style.dart';
import '../../../core/widgets/game_background.dart';
import '../../../core/widgets/game_play_button.dart';
import '../../../routes/app_routes.dart';
import '../binding/home_screen_binding.dart';
import '../controller/home_screen_controller.dart';

// ignore: must_be_immutable
class HomeScreen extends StatekitView<HomeScreenController>
    implements HomeScreenBinding {
  HomeScreen({super.key, super.tag});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameBackground(
        child: SafeArea(
          child: StateBuilder<HomeScreenController>(
            controller: controller,
            builder: (context, controller, child) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          children: [
                            SizedBox(height: constraints.maxHeight * 0.08),
                            _buildLogoSection(),
                            const Spacer(),
                            GamePlayButton(onPressed: controller.onPlayTap),
                            SizedBox(height: constraints.maxHeight * 0.12),
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

  Widget _buildLogoSection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const GameLogoMark(size: 96),
        const SizedBox(height: 20),
        Text(
          'Solitaire',
          style: AppTextStyle.gameTitle(),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Match colours. Solve puzzles.',
          style: AppTextStyle.gameSubtitle(),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  @override
  void onPlayPressed() {
    Navigator.pushNamed(context, Routes.playScreen);
  }
}
