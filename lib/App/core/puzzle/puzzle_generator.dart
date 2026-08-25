import 'dart:math';

import 'category_bank.dart';
import 'puzzle_card.dart';
import 'puzzle_category.dart';
import 'puzzle_content_type.dart';
import 'puzzle_data.dart';
import 'puzzle_difficulty.dart';
import 'puzzle_initial_layout.dart';
import 'puzzle_validator.dart';

class PuzzleGenerator {
  PuzzleGenerator._();

  static final PuzzleGenerator instance = PuzzleGenerator._();

  static const int _maxAttempts = 32;

  PuzzleData generate({required int level, int? seed}) {
    if (level < 1) {
      throw ArgumentError.value(level, 'level', 'must be >= 1');
    }

    final baseSeed = seed ?? _seedForLevel(level);
    PuzzleValidationException? lastError;

    for (var attempt = 0; attempt < _maxAttempts; attempt++) {
      final attemptSeed = baseSeed + attempt * 9973;
      try {
        final puzzle = _buildPuzzle(level: level, seed: attemptSeed);
        PuzzleValidator.validate(puzzle);
        return puzzle;
      } on PuzzleValidationException catch (error) {
        lastError = error;
      }
    }

    throw lastError ??
        PuzzleValidationException('Failed to generate puzzle for level $level');
  }

  int _seedForLevel(int level) {
    return level * 1000003 + CategoryBank.generatorVersion * 7919;
  }

  PuzzleData _buildPuzzle({required int level, required int seed}) {
    final random = Random(seed);
    final config = DifficultyConfig.forLevel(level);
    final selectedEntries = _pickCategories(random, config.categoryCount);

    final categories = <PuzzleCategory>[];
    final cards = <PuzzleCard>[];
    final solution = <String, String>{};
    var cardCounter = 0;

    String nextCardId() {
      cardCounter++;
      return 'c${level}_$cardCounter';
    }

    for (var i = 0; i < selectedEntries.length; i++) {
      final entry = selectedEntries[i];
      final categoryId = 'cat_$i';
      final shuffledItems = List<String>.from(entry.items)..shuffle(random);
      final chosenItems = shuffledItems.take(config.itemsPerCategory).toList();
      final categoryCardIds = <String>[];

      final headerId = nextCardId();
      final headerCard = PuzzleCard(
        id: headerId,
        content: entry.name,
        contentType: PuzzleContentType.word,
        categoryId: categoryId,
        isCategoryHeader: true,
      );
      cards.add(headerCard);
      solution[headerId] = categoryId;

      for (final item in chosenItems) {
        final id = nextCardId();
        final card = PuzzleCard(
          id: id,
          content: item,
          contentType: PuzzleContentType.word,
          categoryId: categoryId,
        );
        cards.add(card);
        categoryCardIds.add(id);
        solution[id] = categoryId;
      }

      categories.add(
        PuzzleCategory(
          id: categoryId,
          name: entry.name,
          requiredItemCount: categoryCardIds.length,
          cardIds: categoryCardIds,
        ),
      );
    }

    final distractorPool = _buildDistractorPool(
      random: random,
      selectedEntries: selectedEntries,
      count: config.distractorCount,
      nextCardId: nextCardId,
    );
    cards.addAll(distractorPool.cards);
    solution.addAll(distractorPool.solution);

    // All cards (category header cards + item cards + distractors) are in the playable deck
    final allPlayableCards = List<PuzzleCard>.from(cards)..shuffle(random);

    final columnCount = categories.length;
    // Distribute initial cards across the tableau columns (2-3 cards per column)
    final cardsPerColumn = (allPlayableCards.length * 0.4 ~/ columnCount).clamp(2, 4);
    final tableauColumns = {
      for (var i = 0; i < columnCount; i++) i: <String>[],
    };

    var cardIndex = 0;
    for (var col = 0; col < columnCount; col++) {
      for (var j = 0; j < cardsPerColumn && cardIndex < allPlayableCards.length; j++) {
        tableauColumns[col]!.add(allPlayableCards[cardIndex].id);
        cardIndex++;
      }
    }

    final categoryColumnIds = categories.map((c) => c.id).toList();

    // Remaining cards go to stock and waste piles
    final remainingCards = allPlayableCards.skip(cardIndex).toList();
    final wasteCount = min(2, max(1, remainingCards.length ~/ 6));
    final stockCount = remainingCards.length - wasteCount;
    final stockCardIds = remainingCards
        .take(stockCount)
        .map((card) => card.id)
        .toList();
    final wasteCardIds = remainingCards
        .skip(stockCount)
        .map((card) => card.id)
        .toList();

    // Face down cards: all stock cards + underlying cards in each tableau column (except top card)
    final faceDownCardIds = Set<String>.from(stockCardIds);
    for (final col in tableauColumns.values) {
      if (col.length > 1) {
        for (var i = 0; i < col.length - 1; i++) {
          faceDownCardIds.add(col[i]);
        }
      }
    }

    final minMoves = allPlayableCards.length + columnCount + 8;
    final maxMoves = max(
      minMoves,
      (allPlayableCards.length * config.maxMovesMultiplier).round() + stockCount,
    );

    return PuzzleData(
      level: level,
      difficulty: config.difficulty,
      categories: categories,
      cards: cards,
      maxMoves: maxMoves,
      initialLayout: PuzzleInitialLayout(
        tableauColumns: tableauColumns,
        stockCardIds: stockCardIds,
        wasteCardIds: wasteCardIds,
        faceDownCardIds: faceDownCardIds,
        categoryColumnIds: categoryColumnIds,
      ),
      solution: solution,
      seed: seed,
      hintCount: config.difficulty.index <= 1 ? 3 : 2,
      undoCount: config.difficulty.index <= 2 ? 3 : 2,
      shuffleCount: 1,
    );
  }

  List<CategoryBankEntry> _pickCategories(Random random, int count) {
    final pool = List<CategoryBankEntry>.from(CategoryBank.entries);
    pool.shuffle(random);
    return pool.take(count.clamp(1, pool.length)).toList();
  }

  _DistractorResult _buildDistractorPool({
    required Random random,
    required List<CategoryBankEntry> selectedEntries,
    required int count,
    required String Function() nextCardId,
  }) {
    final selectedNames = selectedEntries.map((e) => e.name).toSet();
    final pool =
        CategoryBank.entries
            .where((entry) => !selectedNames.contains(entry.name))
            .expand((entry) => entry.items.map((item) => (entry.name, item)))
            .toList()
          ..shuffle(random);

    final cards = <PuzzleCard>[];
    final solution = <String, String>{};

    for (final (categoryName, item) in pool.take(count)) {
      final id = nextCardId();
      final fakeCategoryId = 'distractor_$categoryName';
      final card = PuzzleCard(
        id: id,
        content: item,
        contentType: PuzzleContentType.word,
        categoryId: fakeCategoryId,
        isDistractor: true,
      );
      cards.add(card);
      solution[id] = fakeCategoryId;
    }

    return _DistractorResult(cards: cards, solution: solution);
  }
}

class _DistractorResult {
  const _DistractorResult({required this.cards, required this.solution});
  final List<PuzzleCard> cards;
  final Map<String, String> solution;
}
