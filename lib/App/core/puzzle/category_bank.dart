class CategoryBankEntry {
  const CategoryBankEntry({
    required this.name,
    required this.items,
  });

  final String name;
  final List<String> items;
}

/// Offline static category data used by [PuzzleGenerator].
class CategoryBank {
  CategoryBank._();

  static const int generatorVersion = 1;

  static const List<CategoryBankEntry> entries = [
    CategoryBankEntry(
      name: 'Museum',
      items: ['Display', 'Gallery', 'Exhibit', 'Satin', 'Curator', 'Artifact'],
    ),
    CategoryBankEntry(
      name: 'Seasons',
      items: ['Winter', 'Summer', 'Spring', 'Autumn', 'Fall', 'Solstice'],
    ),
    CategoryBankEntry(
      name: 'Weather',
      items: ['Sunny', 'Rainy', 'Cloudy', 'Storm', 'Windy', 'Foggy'],
    ),
    CategoryBankEntry(
      name: 'Writer',
      items: ['Dickens', 'Twain', 'Faulkner', 'Tolkien', 'Austen', 'Orwell'],
    ),
    CategoryBankEntry(
      name: 'Fishing',
      items: ['Bait', 'Rod', 'Bobber', 'Hook', 'Reel', 'Lure'],
    ),
    CategoryBankEntry(
      name: 'Chess',
      items: ['Pawn', 'Knight', 'Bishop', 'Rook', 'Queen', 'King'],
    ),
    CategoryBankEntry(
      name: 'Kitchen',
      items: ['Spoon', 'Whisk', 'Oven', 'Plate', 'Knife', 'Bowl'],
    ),
    CategoryBankEntry(
      name: 'Ocean',
      items: ['Coral', 'Tide', 'Whale', 'Reef', 'Wave', 'Shell'],
    ),
    CategoryBankEntry(
      name: 'Music',
      items: ['Piano', 'Violin', 'Drums', 'Flute', 'Harp', 'Cello'],
    ),
    CategoryBankEntry(
      name: 'Space',
      items: ['Comet', 'Orbit', 'Nebula', 'Rocket', 'Planet', 'Star'],
    ),
    CategoryBankEntry(
      name: 'Garden',
      items: ['Rose', 'Tulip', 'Shovel', 'Seed', 'Bloom', 'Soil'],
    ),
    CategoryBankEntry(
      name: 'Sports',
      items: ['Soccer', 'Tennis', 'Hockey', 'Rugby', 'Cricket', 'Boxing'],
    ),
    CategoryBankEntry(
      name: 'Colors',
      items: ['Crimson', 'Indigo', 'Violet', 'Amber', 'Teal', 'Olive'],
    ),
    CategoryBankEntry(
      name: 'Animals',
      items: ['Tiger', 'Eagle', 'Dolphin', 'Panda', 'Rabbit', 'Fox'],
    ),
    CategoryBankEntry(
      name: 'Cities',
      items: ['London', 'Paris', 'Tokyo', 'Rome', 'Cairo', 'Sydney'],
    ),
    CategoryBankEntry(
      name: 'Fruits',
      items: ['Apple', 'Mango', 'Peach', 'Grape', 'Melon', 'Berry'],
    ),
    CategoryBankEntry(
      name: 'Tools',
      items: ['Hammer', 'Wrench', 'Saw', 'Drill', 'Pliers', 'Chisel'],
    ),
    CategoryBankEntry(
      name: 'School',
      items: ['Pencil', 'Eraser', 'Ruler', 'Chalk', 'Desk', 'Globe'],
    ),
    CategoryBankEntry(
      name: 'Emotions',
      items: ['Joy', 'Calm', 'Pride', 'Hope', 'Fear', 'Grief'],
    ),
    CategoryBankEntry(
      name: 'Elements',
      items: ['Fire', 'Water', 'Earth', 'Air', 'Metal', 'Wood'],
    ),
    CategoryBankEntry(
      name: 'Birds',
      items: ['Robin', 'Sparrow', 'Heron', 'Finch', 'Crow', 'Swan'],
    ),
    CategoryBankEntry(
      name: 'Desserts',
      items: ['Cake', 'Tart', 'Pudding', 'Cookie', 'Brownie', 'Sorbet'],
    ),
    CategoryBankEntry(
      name: 'Transport',
      items: ['Train', 'Truck', 'Ferry', 'Tram', 'Scooter', 'Subway'],
    ),
    CategoryBankEntry(
      name: 'Fabric',
      items: ['Silk', 'Linen', 'Denim', 'Wool', 'Velvet', 'Satin'],
    ),
    CategoryBankEntry(
      name: 'Jobs',
      items: ['Doctor', 'Pilot', 'Baker', 'Artist', 'Farmer', 'Nurse'],
    ),
    CategoryBankEntry(
      name: 'Shapes',
      items: ['Circle', 'Square', 'Triangle', 'Hexagon', 'Oval', 'Diamond'],
    ),
    CategoryBankEntry(
      name: 'Instruments',
      items: ['Guitar', 'Trumpet', 'Banjo', 'Oboe', 'Sax', 'Ukulele'],
    ),
    CategoryBankEntry(
      name: 'Mountains',
      items: ['Summit', 'Ridge', 'Cliff', 'Peak', 'Valley', 'Slope'],
    ),
    CategoryBankEntry(
      name: 'Drinks',
      items: ['Juice', 'Cocoa', 'Cider', 'Latte', 'Soda', 'Mocha'],
    ),
    CategoryBankEntry(
      name: 'Games',
      items: ['Puzzle', 'Chess', 'Domino', 'Bingo', 'Sudoku', 'Mahjong'],
    ),
  ];
}
