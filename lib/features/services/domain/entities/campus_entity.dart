import 'lat_lng_entity.dart';

class CampusEntity {
  const CampusEntity({
    required this.id,
    required this.title,
    required this.university,
    this.subtitle,
    this.location,
  });

  final String id;
  final String title;
  final String university;
  final String? subtitle;
  final LatLngEntity? location;
}

class CampusSectionEntity {
  const CampusSectionEntity({
    required this.title,
    required this.campuses,
  });

  final String title;
  final List<CampusEntity> campuses;

  int get count => campuses.length;
}
