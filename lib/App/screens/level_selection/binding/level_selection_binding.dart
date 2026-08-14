import 'package:statekit/statekit.dart';

abstract interface class LevelSelectionBinding implements StateBinding {
  void navigateToPlay(int levelNumber);
  void navigateBack();
}