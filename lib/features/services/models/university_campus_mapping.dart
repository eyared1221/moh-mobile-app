class UniversityRecommendedFacility {
  const UniversityRecommendedFacility({
    required this.facilityId,
    required this.name,
    required this.facilityType,
  });

  final String facilityId;
  final String name;
  final String facilityType;
}

class UniversityCampusPresentation {
  const UniversityCampusPresentation({
    required this.title,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
}

class UniversityCampusMapping {
  const UniversityCampusMapping({
    required this.id,
    required this.university,
    required this.group,
    required this.recommendedFacilities,
    required this.status,
    required this.displayTitle,
    this.displaySubtitle,
  });

  final String id;
  final String university;
  final String group;
  final List<UniversityRecommendedFacility> recommendedFacilities;
  final String status;
  final String displayTitle;
  final String? displaySubtitle;
}

String normalizeCampusLookupKey(String value) {
  return value
      .toLowerCase()
      .replaceAll('&', 'and')
      .replaceAll(RegExp(r"[.'(),-]"), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

UniversityCampusPresentation presentUniversityCampus(String universityName) {
  final campusNameMatch =
      RegExp(r'^(.*?)\s*\(([^)]+?)\s+Campus\)$', caseSensitive: false)
          .firstMatch(universityName.trim());

  if (campusNameMatch != null) {
    final baseName = campusNameMatch.group(1)!.trim();
    final campusTown = campusNameMatch.group(2)!.trim();
    return UniversityCampusPresentation(
      title: '$baseName - $campusTown',
      subtitle: campusTown,
    );
  }

  return UniversityCampusPresentation(title: universityName);
}
