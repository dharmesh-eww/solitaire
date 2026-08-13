enum CardZone {
  tableau,
  waste,
  stock,
}

enum GameStatus {
  playing,
  won,
  outOfMoves,
}

class CardLocation {
  const CardLocation({
    required this.zone,
    this.columnIndex,
  });

  final CardZone zone;
  final int? columnIndex;

  CardLocation copyWith({CardZone? zone, int? columnIndex}) {
    return CardLocation(
      zone: zone ?? this.zone,
      columnIndex: columnIndex ?? this.columnIndex,
    );
  }
}
