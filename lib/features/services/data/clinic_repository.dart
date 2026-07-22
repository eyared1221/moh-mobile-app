import 'repositories/clinic_repository_impl.dart';

class ClinicRepository extends ClinicRepositoryImpl {
  ClinicRepository({
    super.remoteDataSource,
    super.localDataSource,
  });
}
