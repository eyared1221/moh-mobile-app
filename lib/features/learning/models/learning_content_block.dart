enum LearningContentType {
  paragraph,
  bullets,
  image,
  subtitle,
  note,
  alphabet,
}

class LearningContentBlock {
  final String id;
  final LearningContentType type;
  final String text;
  final List<String> items;
  final String imageUrl;
  final bool isAssetImage;
  final int order;

  const LearningContentBlock({
    required this.id,
    required this.type,
    required this.text,
    required this.items,
    required this.imageUrl,
    required this.isAssetImage,
    required this.order,
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