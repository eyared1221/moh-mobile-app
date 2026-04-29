import 'lat_lng_entity.dart';

class ClinicEntity {
  final String id;
  final String name;
  final String address;
  final String phone;
  final String? email;
  final String? website;
  final String hours;
  final String description;
  final List<String> services;
  final LatLngEntity location;
  final String? imageUrl;
  final String? altitude;

  const ClinicEntity({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    this.email,
    this.website,
    required this.hours,
    required this.description,
    required this.services,
    required this.location,
    this.imageUrl,
    this.altitude,
  });
}
