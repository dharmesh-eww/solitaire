import 'package:flutter/material.dart';
import 'package:statekit/statekit.dart';

import './app_routes.dart';
import '../screens/home_screen/controller/home_screen_controller.dart';
import '../screens/home_screen/view/home_screen.dart';
import '../screens/splash_screen/view/splash_screen.dart';
import '../screens/play_screen/view/play_screen.dart';
import '../screens/play_screen/controller/play_screen_controller.dart';
import '../screens/level_selection/view/level_selection.dart';
import '../screens/level_selection/controller/level_selection_controller.dart';
import '../screens/level_complete/view/level_complete.dart';
import '../screens/level_complete/controller/level_complete_controller.dart';

abstract class RouteNavigator {
  static final Map<String, Widget Function(BuildContext)> routes = {
    Routes.splash: (BuildContext context) => const SplashScreen(),
    Routes.homeScreen: (BuildContext context) => StateProvider(
      stateProvider: StatekitProvider(create: () => HomeScreenController()),
      child: HomeScreen(),
    ),
    Routes.playScreen: (BuildContext context) {
      final level = (ModalRoute.of(context)?.settings.arguments as int?) ?? 1;
      return StateProvider(
        stateProvider: StatekitProvider(create: () => PlayScreenController(level: level)),
        child: PlayScreen(),
      );
    },
    Routes.levelSelection: (BuildContext context) => StateProvider(
      stateProvider: StatekitProvider(create: () => LevelSelectionController()),
      child: LevelSelection(),
    ),
    Routes.levelComplete: (BuildContext context) => StateProvider(
      stateProvider: StatekitProvider(create: () => LevelCompleteController()),
      child: LevelComplete(),
    ),
  };
}
