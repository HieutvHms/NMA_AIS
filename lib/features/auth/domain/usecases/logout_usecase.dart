import '../repositories/auth_repository.dart';

class LogoutUseCase {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  Future<void> call({bool callRemote = true}) {
    return repository.logout(callRemote: callRemote);
  }
}

