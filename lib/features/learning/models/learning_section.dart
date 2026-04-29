import 'learning_content_block.dart';
import '../domain/entities/learning_section_entity.dart';

class LearningSection extends LearningSectionEntity {
  const LearningSection({
    required super.id,
    required super.title,
    required super.order,
    required List<LearningContentBlock> super.blocks,
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
      'blocks': blocks
          .map((e) => (e as LearningContentBlock).toJson())
          .toList(),
    };
  }
}
