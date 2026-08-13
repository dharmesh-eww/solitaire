import 'puzzle_content_type.dart';

class PuzzleCard {
  const PuzzleCard({
    required this.id,
    required this.content,
    required this.contentType,
    required this.categoryId,
    this.isDistractor = false,
    this.isCategoryHeader = false,
  });

  final String id;
  final String content;
  final PuzzleContentType contentType;
  final String categoryId;
  final bool isDistractor;
  final bool isCategoryHeader;

  PuzzleCard copyWith({
    String? id,
    String? content,
    PuzzleContentType? contentType,
    String? categoryId,
    bool? isDistractor,
    bool? isCategoryHeader,
  }) {
    return PuzzleCard(
      id: id ?? this.id,
      content: content ?? this.content,
      contentType: contentType ?? this.contentType,
      categoryId: categoryId ?? this.categoryId,
      isDistractor: isDistractor ?? this.isDistractor,
      isCategoryHeader: isCategoryHeader ?? this.isCategoryHeader,
    );
  }
}
