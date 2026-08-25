import 'package:statekit/statekit.dart';
import '../../level_complete/model/level_complete_data.dart';

abstract interface class PlayScreenBinding implements StateBinding {
  void onLevelCompleted(LevelCompleteData data);
}