import 'learning_section_entity.dart';

enum ModuleImagePosition { top, bottom }

class LearningModuleEntity {
  final String id;
  final String title;
  final String shortDescription;
  final String ctaLabel;
  final String introText;
  final String definitionTitle;
  final String note;
  final String imageUrl;
  final bool isAssetImage;
  final ModuleImagePosition imagePosition;
  final int displayOrder;
  final List<LearningSectionEntity> sections;

  const LearningModuleEntity({
    required this.id,
    required this.title,
    required this.shortDescription,
    required this.ctaLabel,
    required this.introText,
    required this.definitionTitle,
    required this.note,
    required this.imageUrl,
    required this.isAssetImage,
    required this.imagePosition,
    required this.displayOrder,
    required this.sections,
  });
}
