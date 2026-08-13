class PuzzleInitialLayout {
  const PuzzleInitialLayout({
    required this.tableauColumns,
    required this.stockCardIds,
    required this.wasteCardIds,
    required this.faceDownCardIds,
    required this.categoryColumnIds,
  });

  /// Column index -> card ids from bottom to top.
  final Map<int, List<String>> tableauColumns;
  final List<String> stockCardIds;
  final List<String> wasteCardIds;
  final Set<String> faceDownCardIds;
  final List<String> categoryColumnIds;
}
