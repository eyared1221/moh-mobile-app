import 'learning_section.dart';

enum ModuleImagePosition { top, bottom }

class LearningModule {
  final String id;
  final String title;
  final String shortDescription;
  final String ctaLabel;
  final String introText;
  final String note;
  final String imageUrl;
  final bool isAssetImage;
  final ModuleImagePosition imagePosition;
  final int displayOrder;
  final List<LearningSection> sections;

  const LearningModule({
    required this.id,
    required this.title,
    required this.shortDescription,
    this.ctaLabel = 'More',
    required this.introText,
    required this.note,
    required this.imageUrl,
    required this.isAssetImage,
    required this.imagePosition,
    this.displayOrder = 0,
    required this.sections,
  });

  factory LearningModule.fromJson(Map<String, dynamic> json) {
    final rawSections = (json['sections'] as List<dynamic>? ?? []);

    return LearningModule(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      shortDescription: json['shortDescription']?.toString() ?? '',
      ctaLabel: json['ctaLabel']?.toString() ?? 'More',
      introText: json['introText']?.toString() ?? '',
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
      'note': note,
      'imageUrl': imageUrl,
      'isAssetImage': isAssetImage,
      'imagePosition': imagePosition == ModuleImagePosition.top ? 'top' : 'bottom',
      'displayOrder': displayOrder,
      'sections': sections.map((e) => e.toJson()).toList(),
    };
  }
}
