import '../entities/register_result_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  const RegisterUseCase(this._repository);

  final AuthRepository _repository;

  Future<RegisterResultEntity> call({
    required String email,
    required String username,
    required String phone,
    required int age,
    required String password,
  }) {
    return _repository.register(
      email: email,
      username: username,
      phone: phone,
      age: age,
      password: password,
    );
  }
}
