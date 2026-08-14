import 'package:flutter/material.dart';
import 'package:statekit/statekit.dart';
import '../../play_screen/view/widgets/game_table_background.dart';
import '../../../routes/app_routes.dart';
import '../binding/level_selection_binding.dart';
import '../controller/level_selection_controller.dart';
import 'widgets/journey_header.dart';
import 'widgets/journey_map.dart';

class LevelSelection extends StatekitView<LevelSelectionController> implements LevelSelectionBinding {
  LevelSelection({super.key, super.tag});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameTableBackground(
        child: SafeArea(
          child: StateBuilder<LevelSelectionController>(
            controller: controller,
            builder: (context, controller, child) {
              return Column(
                children: [
                  JourneyHeader(
                    coins: controller.coins,
                    onBack: controller.onBackTap,
                    onSettings: controller.onSettingsTap,
                  ),
                  Expanded(
                    child: JourneyMap(
                      controller: controller,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  void navigateToPlay(int levelNumber) {
    Navigator.pushNamed(context, Routes.playScreen);
  }

  @override
  void navigateBack() {
    Navigator.pop(context);
  }
}