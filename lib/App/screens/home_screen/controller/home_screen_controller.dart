import 'package:statekit/statekit.dart';
import '../binding/home_screen_binding.dart';

class HomeScreenController extends StateController<HomeScreenBinding> {
  void onPlayTap() {
    binding?.onPlayPressed();
  }
}
