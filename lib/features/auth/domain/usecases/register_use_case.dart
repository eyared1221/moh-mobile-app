import '../entities/register_result_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  const RegisterUseCase(this._repository);

  final AuthRepository _repository;

  Future<RegisterResultEntity> call({
    required String contact,
    required String username,
    required int age,
    required String password,
  }) {
    return _repository.register(
      contact: contact,
      username: username,
      age: age,
      password: password,
    );
  }
}
