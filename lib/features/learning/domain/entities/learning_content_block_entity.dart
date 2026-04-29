enum LearningContentType {
  paragraph,
  bullets,
  image,
  subtitle,
  note,
  alphabet,
}

class LearningContentBlockEntity {
  final String id;
  final LearningContentType type;
  final String text;
  final List<String> items;
  final String imageUrl;
  final bool isAssetImage;
  final int order;

  const LearningContentBlockEntity({
    required this.id,
    required this.type,
    required this.text,
    required this.items,
    required this.imageUrl,
    required this.isAssetImage,
    required this.order,
  });
}
