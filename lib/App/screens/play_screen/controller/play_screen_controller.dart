import 'package:statekit/statekit.dart';
import '../binding/play_screen_binding.dart';
import '../engine/game_engine.dart';
import '../model/game_state.dart';

class PlayScreenController extends StateController<PlayScreenBinding> {
  final GameEngine engine = GameEngine.forLevel(3);

  GameState get state => engine.state;
  int get level => state.puzzle.level;

  bool isPlayable(String cardId) => engine.isPlayable(cardId);

  bool isFaceUp(String cardId) => engine.isFaceUp(cardId);

  bool canDropOnCategory(String cardId, int columnIndex) {
    final categoryId = engine.categoryIdForColumn(columnIndex);
    return categoryId != null && engine.canDropOnCategory(cardId, categoryId);
  }

  void selectCard(String? cardId) {
    engine.selectCard(cardId);
    update();
  }

  void tapCategory(int columnIndex) {
    engine.tapCategory(columnIndex);
    update();
  }

  void moveCardToCategory(String cardId, int columnIndex) {
    engine.moveCardToCategory(cardId, columnIndex, consumeMove: true);
    update();
  }

  void drawFromStock() {
    engine.drawFromStock();
    update();
  }

  void useHint() {
    engine.useHint();
    update();
  }

  void undo() {
    engine.undo();
    update();
  }

  void shuffle() {
    engine.shuffleTableau();
    update();
  }

  void retryLevel() {
    engine.retryLevel();
    update();
  }
}
