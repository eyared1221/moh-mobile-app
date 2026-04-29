import 'learning_section.dart';
import '../domain/entities/learning_module_entity.dart';

class LearningModule extends LearningModuleEntity {
  const LearningModule({
    required super.id,
    required super.title,
    required super.shortDescription,
    super.ctaLabel = 'More',
    required super.introText,
    super.definitionTitle = 'Note',
    required super.note,
    required super.imageUrl,
    required super.isAssetImage,
    required super.imagePosition,
    super.displayOrder = 0,
    required List<LearningSection> super.sections,
  });

  factory LearningModule.fromJson(Map<String, dynamic> json) {
    final rawSections = (json['sections'] as List<dynamic>? ?? []);

    return LearningModule(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      shortDescription: json['shortDescription']?.toString() ?? '',
      ctaLabel: json['ctaLabel']?.toString() ?? 'More',
      introText: json['introText']?.toString() ?? '',
      definitionTitle: json['definitionTitle']?.toString() ?? 'Note',
      note: json['note']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      isAssetImage: json['isAssetImage'] == true,
      imagePosition: (json['imagePosition']?.toString() == 'top')
          ? ModuleImagePosition.top
          : ModuleImagePosition.bottom,
      displayOrder: json['displayOrder'] is int
          ? json['displayOrder']
          : int.tryParse('${json['displayOrder']}') ?? 0,
      sections: rawSections
          .map((e) => LearningSection.fromJson(e as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => a.order.compareTo(b.order)),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'shortDescription': shortDescription,
      'ctaLabel': ctaLabel,
      'introText': introText,
      'definitionTitle': definitionTitle,
      'note': note,
      'imageUrl': imageUrl,
      'isAssetImage': isAssetImage,
      'imagePosition': imagePosition == ModuleImagePosition.top ? 'top' : 'bottom',
      'displayOrder': displayOrder,
      'sections': sections.map((e) => (e as LearningSection).toJson()).toList(),
    };
  }
}
