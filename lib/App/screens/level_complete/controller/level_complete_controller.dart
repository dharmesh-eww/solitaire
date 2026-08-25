import 'package:statekit/statekit.dart';
import '../repository/level_complete_repository.dart';
import '../binding/level_complete_binding.dart';

class LevelCompleteController extends StateController<LevelCompleteBinding> {
  final LevelCompleteRepository _repository = LevelCompleteRepository();

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
