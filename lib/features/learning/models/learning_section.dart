import 'learning_content_block.dart';

class LearningSection {
  final String id;
  final String title;
  final int order;
  final List<LearningContentBlock> blocks;

  const LearningSection({
    required this.id,
    required this.title,
    required this.order,
    required this.blocks,
  });

  factory LearningSection.fromJson(Map<String, dynamic> json) {
    final rawBlocks = (json['blocks'] as List<dynamic>? ?? []);

    return LearningSection(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      order: json['order'] is int
          ? json['order']
          : int.tryParse('${json['order']}') ?? 0,
      blocks: rawBlocks
          .map((e) => LearningContentBlock.fromJson(e as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => a.order.compareTo(b.order)),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'order': order,
      'blocks': blocks.map((e) => e.toJson()).toList(),
    };
  }
}