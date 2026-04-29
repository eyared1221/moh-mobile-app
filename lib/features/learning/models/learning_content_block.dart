import '../domain/entities/learning_content_block_entity.dart';

class LearningContentBlock extends LearningContentBlockEntity {
  const LearningContentBlock({
    required super.id,
    required super.type,
    required super.text,
    required super.items,
    required super.imageUrl,
    required super.isAssetImage,
    required super.order,
  });

  factory LearningContentBlock.fromJson(Map<String, dynamic> json) {
    final rawItems = (json['items'] as List<dynamic>? ?? []);

    return LearningContentBlock(
      id: json['id']?.toString() ?? '',
      type: _parseType(json['type']?.toString()),
      text: json['text']?.toString() ?? '',
      items: rawItems.map((e) => e.toString()).toList(),
      imageUrl: json['imageUrl']?.toString() ?? '',
      isAssetImage: json['isAssetImage'] == true,
      order: json['order'] is int
          ? json['order']
          : int.tryParse('${json['order']}') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'text': text,
      'items': items,
      'imageUrl': imageUrl,
      'isAssetImage': isAssetImage,
      'order': order,
    };
  }

  static LearningContentType _parseType(String? value) {
    switch (value) {
      case 'bullets':
        return LearningContentType.bullets;
      case 'image':
        return LearningContentType.image;
      case 'subtitle':
        return LearningContentType.subtitle;
      case 'note':
        return LearningContentType.note;
      case 'alphabet':
        return LearningContentType.alphabet;
      case 'paragraph':
      default:
        return LearningContentType.paragraph;
    }
  }
}
