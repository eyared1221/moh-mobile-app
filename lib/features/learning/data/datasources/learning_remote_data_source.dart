import '../../domain/entities/learning_content_block_entity.dart';
import '../../domain/entities/learning_module_entity.dart';
import '../../models/learning_content_block.dart';
import '../../models/learning_module.dart';
import '../../models/learning_section.dart';
import '../learning_api_client.dart';

class LearningRemoteDataSource {
  LearningRemoteDataSource({LearningApiClient? apiClient})
      : _apiClient = apiClient ?? LearningApiClient();

  final LearningApiClient _apiClient;

  Future<Map<String, dynamic>> fetchModulesPayload() {
    return _apiClient.get('/modules');
  }

  Future<Map<String, dynamic>> fetchModuleDetailPayload(String slug) {
    return _apiClient.get('/modules/$slug');
  }

  List<LearningModule> mapModulesPayload(Map<String, dynamic> payload) {
    final data = payload['data'] as List<dynamic>;

    final modules = data
        .map(
          (moduleJson) => mapModuleJson(
            moduleJson as Map<String, dynamic>,
          ),
        )
        .toList()
      ..sort((a, b) {
        final orderComparison = a.displayOrder.compareTo(b.displayOrder);
        if (orderComparison != 0) {
          return orderComparison;
        }

        return a.title.compareTo(b.title);
      });

    return modules;
  }

  LearningModule mapModuleDetailPayload(Map<String, dynamic> payload) {
    final data = payload['data'] as Map<String, dynamic>;
    return mapModuleJson(data);
  }

  LearningModule mapModuleJson(Map<String, dynamic> json) {
    final sectionsJson = json['sections'] as List<dynamic>? ?? [];
    final sections = sectionsJson
        .map(
          (sectionJson) => _mapToLearningSection(
            sectionJson as Map<String, dynamic>,
          ),
        )
        .toList();
    final slug = json['slug'] as String;

    return LearningModule(
      id: slug,
      title: json['title'] as String? ?? json['moduleName'] as String? ?? '',
      shortDescription: json['subtitle'] as String? ?? '',
      ctaLabel: json['ctaLabel'] as String? ?? 'More',
      introText: json['introSummary'] as String? ?? '',
      definitionTitle: json['definitionTitle'] as String? ?? 'Note',
      note: json['definitionBody'] as String? ?? '',
      imageUrl: json['landingImageUrl'] as String? ?? '',
      isAssetImage: false,
      imagePosition: ModuleImagePosition.top,
      displayOrder: json['displayOrder'] is int
          ? json['displayOrder']
          : int.tryParse('${json['displayOrder']}') ?? 0,
      sections: sections,
    );
  }

  LearningSection _mapToLearningSection(Map<String, dynamic> json) {
    final blocksJson = json['blocks'] as List<dynamic>? ?? [];
    final blocks = blocksJson
        .map(
          (blockJson) => _mapToLearningContentBlock(
            blockJson as Map<String, dynamic>,
          ),
        )
        .toList();

    return LearningSection(
      id: json['id'] as String,
      title: json['title'] as String,
      order: 0,
      blocks: blocks,
    );
  }

  LearningContentBlock _mapToLearningContentBlock(Map<String, dynamic> json) {
    final type = _mapContentType(json['type'] as String);
    final value = json['value'] as String? ?? '';

    List<String> items = [];
    if (type == LearningContentType.bullets ||
        type == LearningContentType.alphabet) {
      items = value
          .split('\n')
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }

    return LearningContentBlock(
      id: json['id'] as String,
      type: type,
      text: value,
      items: items,
      imageUrl: json['imageUrl'] as String? ?? '',
      isAssetImage: false,
      order: 0,
    );
  }

  LearningContentType _mapContentType(String backendType) {
    switch (backendType) {
      case 'text':
        return LearningContentType.paragraph;
      case 'video':
        return LearningContentType.video;
      case 'subtitle':
        return LearningContentType.subtitle;
      case 'bulletList':
        return LearningContentType.bullets;
      case 'numberList':
        return LearningContentType.bullets;
      case 'alphabetList':
        return LearningContentType.alphabet;
      case 'image':
        return LearningContentType.image;
      case 'table':
        return LearningContentType.paragraph;
      default:
        return LearningContentType.paragraph;
    }
  }
}
