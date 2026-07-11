import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

/// Use case encapsulating the "login with a social provider" flow.
class LoginWithProviderUseCase {
  const LoginWithProviderUseCase(this._repository);

  final AuthRepository _repository;

  Future<AuthUser> call(AuthProviderType provider) {
    return _repository.loginWithProvider(provider);
  }
}
