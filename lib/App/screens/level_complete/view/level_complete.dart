import 'package:statekit/statekit.dart';
import 'package:flutter/material.dart';
import '../../base_screen/view/base_screen.dart';
import '../../base_screen/view/custom_appbar.dart';
import '../binding/level_complete_binding.dart';
import '../controller/level_complete_controller.dart';

class LevelComplete extends StatekitView<LevelCompleteController> implements LevelCompleteBinding {
  LevelComplete({super.key, super.tag});

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      appBar: CustomAppbar(title: Text("level complete")),
      body: StateBuilder<LevelCompleteController>(
        controller: controller,
        builder: (context, controller, child) {
          return Center(child: Text("level complete"));
        },
      ),
    );
  }

  @override
  void doSomething() {}
}
