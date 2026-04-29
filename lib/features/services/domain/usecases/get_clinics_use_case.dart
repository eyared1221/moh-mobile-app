import '../entities/clinic_entity.dart';
import '../repositories/clinic_repository.dart';

class GetClinicsUseCase {
  const GetClinicsUseCase(this._repository);

  final ClinicRepository _repository;

  Future<List<ClinicEntity>> call() {
    return _repository.fetchClinics();
  }
}
