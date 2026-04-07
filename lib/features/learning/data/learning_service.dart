import '../models/learning_module.dart';
import '../models/learning_section.dart';
import '../models/learning_content_block.dart';
import 'learning_api_client.dart';

class LearningService {
  LearningService({
    LearningApiClient? apiClient,
  }) : _apiClient = apiClient ?? LearningApiClient();

  final LearningApiClient _apiClient;

  static final LearningService instance = LearningService();

  Future<List<LearningModule>> getLearningModules() async {
    try {
      final payload = await _apiClient.get('/modules');
      final data = payload['data'] as List<dynamic>;

      final modules = data
          .map((moduleJson) => _mapToLearningModule(moduleJson as Map<String, dynamic>))
          .toList()
        ..sort((a, b) {
          final orderComparison = a.displayOrder.compareTo(b.displayOrder);
          if (orderComparison != 0) {
            return orderComparison;
          }

          return a.title.compareTo(b.title);
        });

      return modules;
    } catch (e) {
      throw LearningServiceException('Failed to load learning modules: $e');
    }
  }

  Future<LearningModule> getLearningModuleBySlug(String slug) async {
    try {
      final payload = await _apiClient.get('/modules/$slug');
      final data = payload['data'] as Map<String, dynamic>;
      
      return _mapToLearningModule(data);
    } catch (e) {
      throw LearningServiceException('Failed to load learning module: $e');
    }
  }

  LearningModule _mapToLearningModule(Map<String, dynamic> json) {
    final sectionsJson = json['sections'] as List<dynamic>? ?? [];
    final sections = sectionsJson
        .map((sectionJson) => _mapToLearningSection(sectionJson as Map<String, dynamic>))
        .toList();
    final slug = json['slug'] as String;

    return LearningModule(
      id: slug,
      title: json['moduleName'] as String,
      shortDescription: json['subtitle'] as String? ?? '',
      introText: json['introSummary'] as String? ?? '',
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
        .map((blockJson) => _mapToLearningContentBlock(blockJson as Map<String, dynamic>))
        .toList();

    return LearningSection(
      id: json['id'] as String,
      title: json['title'] as String,
      order: 0, // Order not needed from backend
      blocks: blocks,
    );
  }

  LearningContentBlock _mapToLearningContentBlock(Map<String, dynamic> json) {
    final type = _mapContentType(json['type'] as String);
    final value = json['value'] as String? ?? '';
    
    // Parse list items from value field for bullet/alphabet lists
    List<String> items = [];
    if (type == LearningContentType.bullets || type == LearningContentType.alphabet) {
      items = value.split('\n').map((item) => item.trim()).where((item) => item.isNotEmpty).toList();
    }
    
    return LearningContentBlock(
      id: json['id'] as String,
      type: type,
      text: value,
      items: items,
      imageUrl: json['imageUrl'] as String? ?? '',
      isAssetImage: false, // Backend URLs are network images
      order: 0, // Order not needed from backend
    );
  }

  LearningContentType _mapContentType(String backendType) {
    switch (backendType) {
      case 'text':
        return LearningContentType.paragraph;
      case 'subtitle':
        return LearningContentType.subtitle;
      case 'bulletList':
        return LearningContentType.bullets;
      case 'numberList':
        return LearningContentType.bullets; // Map numbered lists to bullets
      case 'alphabetList':
        return LearningContentType.alphabet; // Map alphabet lists to alphabet type
      case 'image':
        return LearningContentType.image;
      case 'table':
        return LearningContentType.paragraph; // Tables displayed as paragraphs for now
      default:
        return LearningContentType.paragraph;
    }
  }
}

class LearningServiceException implements Exception {
  const LearningServiceException(this.message);

  final String message;

  @override
  String toString() => 'LearningServiceException: $message';
}
