import 'package:statekit/statekit.dart';

abstract interface class LevelCompleteBinding implements StateBinding {
  void onNextLevel(int nextLevel);
  void onReplayLevel(int levelNumber);
  void onLevelsPressed();
  void onHomePressed();
}