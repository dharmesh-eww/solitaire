class PuzzleCategory {
  const PuzzleCategory({
    required this.id,
    required this.name,
    required this.requiredItemCount,
    required this.cardIds,
  });

  final String id;
  final String name;
  final int requiredItemCount;
  final List<String> cardIds;

  PuzzleCategory copyWith({
    String? id,
    String? name,
    int? requiredItemCount,
    List<String>? cardIds,
  }) {
    return PuzzleCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      requiredItemCount: requiredItemCount ?? this.requiredItemCount,
      cardIds: cardIds ?? List<String>.from(this.cardIds),
    );
  }
}
