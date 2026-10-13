import '../../../../core/failures.dart';
import '../repositories/auth_repository.dart';

class Logout {
  const Logout(this._repository);

  final AuthRepository _repository;

  Future<({Failure? failure})> call() {
    return _repository.logout();
  }
}
