import '../../models/clinic.dart';
import '../../models/university_campus_mapping.dart';

abstract class CampusRepository {
  Future<List<UniversityCampusMapping>> fetchUniversityMappings();
  Future<List<Clinic>> fetchClinics();
}
