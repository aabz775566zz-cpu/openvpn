import '../entities/auth_user.dart';

/// Repository abstraction for authentication operations.
abstract class AuthRepository {
  Future<AuthUser> loginWithProvider(AuthProviderType provider);
  Future<void> logout();
  AuthUser? get currentUser;
}
