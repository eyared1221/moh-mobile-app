import 'dart:math' as math;

import '../../domain/entities/clinic_entity.dart';
import '../../domain/entities/lat_lng_entity.dart';
import '../../domain/usecases/get_clinics_use_case.dart';

class ClinicPageController {
  const ClinicPageController(this._getClinicsUseCase);

  final GetClinicsUseCase _getClinicsUseCase;

  Future<List<ClinicEntity>> loadClinics() {
    return _getClinicsUseCase();
  }

  List<ClinicEntity> filterClinics(List<ClinicEntity> clinics, String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) {
      return clinics;
    }

    return clinics.where((clinic) {
      final inName = clinic.name.toLowerCase().contains(normalized);
      final inAddress = clinic.address.toLowerCase().contains(normalized);
      final inServices =
          clinic.services.any((service) => service.toLowerCase().contains(normalized));
      return inName || inAddress || inServices;
    }).toList();
  }

  List<ClinicEntity> nearbyClinics(
    List<ClinicEntity> clinics, {
    required String query,
    required LatLngEntity? userLocation,
    required int maxNearbyClinics,
  }) {
    final filtered = filterClinics(clinics, query);
    if (userLocation == null) {
      return filtered.take(maxNearbyClinics).toList();
    }

    final sorted = [...filtered]
      ..sort(
        (a, b) => distanceKm(a, userLocation).compareTo(
          distanceKm(b, userLocation),
        ),
      );
    return sorted.take(maxNearbyClinics).toList();
  }

  double distanceKm(ClinicEntity clinic, LatLngEntity userLocation) {
    return _haversineKm(
      userLocation.latitude,
      userLocation.longitude,
      clinic.location.latitude,
      clinic.location.longitude,
    );
  }

  double _haversineKm(double lat1, double lon1, double lat2, double lon2) {
    const earthRadiusKm = 6371.0;
    final dLat = _degToRad(lat2 - lat1);
    final dLon = _degToRad(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degToRad(lat1)) *
            math.cos(_degToRad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  double _degToRad(double deg) => deg * (math.pi / 180.0);
}
