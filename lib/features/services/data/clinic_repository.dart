import '../domain/entities/clinic_entity.dart';
import 'repositories/clinic_repository_impl.dart';

class ClinicRepository extends ClinicRepositoryImpl {
  ClinicRepository({
    super.remoteDataSource,
    super.localDataSource,
  });

  @override
  Future<List<ClinicEntity>> fetchClinics() {
    return super.fetchClinics();
  }
}
