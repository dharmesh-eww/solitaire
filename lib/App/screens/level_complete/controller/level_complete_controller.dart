import 'package:statekit/statekit.dart';
import '../../level_selection/repository/level_selection_repository.dart';
import '../binding/level_complete_binding.dart';
import '../model/level_complete_data.dart';

class LevelCompleteController extends StateController<LevelCompleteBinding> {
  LevelCompleteController({LevelCompleteData? data})
      : data = data ?? LevelCompleteData.fallback;

  final LevelCompleteData data;
  final LevelSelectionRepository _repository = LevelSelectionRepository();

  int _totalCoins = 566;
  int get totalCoins => _totalCoins;

  @override
  void onInit() {
    super.onInit();
    _saveProgressAndRewards();
  }

  Future<void> _saveProgressAndRewards() async {
    try {
      final currentCoins = await _repository.getCoins();
      _totalCoins = currentCoins + data.coinsReward;
      await _repository.setCoins(_totalCoins);

      await _repository.updateLevelCompletion(
        data.levelNumber,
        data.stars,
        data.score,
      );

      await _repository.setCurrentLevel(data.nextLevel);
      update();
    } catch (_) {}
  }

  void onNextLevelTap() {
    binding?.onNextLevel(data.nextLevel);
  }

  void onReplayTap() {
    binding?.onReplayLevel(data.levelNumber);
  }

  void onLevelsTap() {
    binding?.onLevelsPressed();
  }

  void onHomeTap() {
    binding?.onHomePressed();
  }
}
