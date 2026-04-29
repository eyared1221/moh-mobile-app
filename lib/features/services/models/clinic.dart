import '../domain/entities/clinic_entity.dart';
import '../domain/entities/lat_lng_entity.dart';

class Clinic extends ClinicEntity {
  const Clinic({
    required super.id,
    required super.name,
    required super.address,
    required super.phone,
    super.email,
    super.website,
    required super.hours,
    required super.description,
    required super.services,
    required LatLng super.location,
    super.imageUrl,
    super.altitude,
  });
}

class LatLng extends LatLngEntity {
  const LatLng(double latitude, double longitude) : super(latitude, longitude);
}
