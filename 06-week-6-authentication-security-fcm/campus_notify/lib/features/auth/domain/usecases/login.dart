import '../../../../core/failures.dart';
import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

class Login {
  const Login(this._repository);

  final AuthRepository _repository;

  Future<({AuthSession? session, Failure? failure})> call(
    String email,
    String password,
  ) {
    return _repository.login(email: email, password: password);
  }
}
