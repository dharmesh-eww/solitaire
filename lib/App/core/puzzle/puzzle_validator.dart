import 'puzzle_data.dart';

class PuzzleValidationException implements Exception {
  PuzzleValidationException(this.message);
  final String message;

  @override
  String toString() => 'PuzzleValidationException: $message';
}

class PuzzleValidator {
  PuzzleValidator._();

  static void validate(PuzzleData puzzle) {
    if (puzzle.level < 1) {
      throw PuzzleValidationException('Level must be >= 1');
    }
    if (puzzle.categories.isEmpty) {
      throw PuzzleValidationException('Puzzle must contain categories');
    }
    if (puzzle.cards.isEmpty) {
      throw PuzzleValidationException('Puzzle must contain cards');
    }

    final cardIds = <String>{};
    for (final card in puzzle.cards) {
      if (!cardIds.add(card.id)) {
        throw PuzzleValidationException('Duplicate card id: ${card.id}');
      }
      if (puzzle.categoryById(card.categoryId) == null &&
          !card.isCategoryHeader &&
          !card.isDistractor) {
        throw PuzzleValidationException(
          'Card ${card.id} references invalid category ${card.categoryId}',
        );
      }
    }

    for (final category in puzzle.categories) {
      if (category.requiredItemCount <= 0) {
        throw PuzzleValidationException(
          'Category ${category.id} must require at least one item',
        );
      }
      if (category.cardIds.length != category.requiredItemCount) {
        throw PuzzleValidationException(
          'Category ${category.id} card count mismatch',
        );
      }
      for (final cardId in category.cardIds) {
        if (!cardIds.contains(cardId)) {
          throw PuzzleValidationException(
            'Category ${category.id} references missing card $cardId',
          );
        }
      }
    }

    if (puzzle.solution.length != puzzle.cards.length) {
      throw PuzzleValidationException('Solution must include every card');
    }
    for (final card in puzzle.cards) {
      final mapped = puzzle.solution[card.id];
      if (mapped == null) {
        throw PuzzleValidationException('Missing solution for ${card.id}');
      }
      if (mapped != card.categoryId) {
        throw PuzzleValidationException('Solution mismatch for ${card.id}');
      }
    }

    final layoutIds = <String>{};
    for (final column in puzzle.initialLayout.tableauColumns.values) {
      for (final id in column) {
        if (!layoutIds.add(id)) {
          throw PuzzleValidationException('Duplicate layout card id: $id');
        }
      }
    }
    for (final id in puzzle.initialLayout.stockCardIds) {
      if (!layoutIds.add(id)) {
        throw PuzzleValidationException('Duplicate stock card id: $id');
      }
    }
    for (final id in puzzle.initialLayout.wasteCardIds) {
      if (!layoutIds.add(id)) {
        throw PuzzleValidationException('Duplicate waste card id: $id');
      }
    }

    if (layoutIds.length != puzzle.cards.length) {
      throw PuzzleValidationException('Layout must contain all cards once');
    }

    for (final id in layoutIds) {
      if (!cardIds.contains(id)) {
        throw PuzzleValidationException('Layout references unknown card $id');
      }
    }

    if (puzzle.maxMoves <= 0) {
      throw PuzzleValidationException('maxMoves must be positive');
    }

    if (puzzle.initialLayout.categoryColumnIds.length !=
        puzzle.categories.length) {
      throw PuzzleValidationException('Category column count mismatch');
    }
  }
}
