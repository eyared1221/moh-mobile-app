import 'learning_content_block_entity.dart';

class LearningSectionEntity {
  final String id;
  final String title;
  final int order;
  final List<LearningContentBlockEntity> blocks;

  const LearningSectionEntity({
    required this.id,
    required this.title,
    required this.order,
    required this.blocks,
  });
}
