import 'package:flutter_test/flutter_test.dart';
import 'package:openworld_vpn_mobile/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:openworld_vpn_mobile/features/auth/data/models/auth_user_model.dart';
import 'package:openworld_vpn_mobile/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:openworld_vpn_mobile/features/auth/domain/entities/auth_user.dart';
import 'package:openworld_vpn_mobile/features/auth/domain/usecases/login_with_provider_usecase.dart';
import 'package:openworld_vpn_mobile/features/auth/presentation/controllers/auth_controller.dart';

class _FakeAuthRemoteDataSource implements AuthRemoteDataSource {
  _FakeAuthRemoteDataSource({this.failure});

  final Object? failure;
  AuthProviderType? lastProvider;

  @override
  Future<AuthUserModel> loginWithProvider(AuthProviderType provider) async {
    lastProvider = provider;
    if (failure != null) throw failure!;
    return AuthUserModel(
      id: 'fake-${provider.name}',
      displayName: 'Fake User',
      provider: provider,
    );
  }
}

void main() {
  group('LoginWithProviderUseCase / AuthRepositoryImpl', () {
    test('returns the authenticated user on success', () async {
      final dataSource = _FakeAuthRemoteDataSource();
      final repository = AuthRepositoryImpl(dataSource);
      final useCase = LoginWithProviderUseCase(repository);

      final user = await useCase(AuthProviderType.google);

      expect(user.id, 'fake-google');
      expect(dataSource.lastProvider, AuthProviderType.google);
      expect(repository.currentUser, isNotNull);
    });

    test('logout clears the current user', () async {
      final repository = AuthRepositoryImpl(_FakeAuthRemoteDataSource());
      await repository.loginWithProvider(AuthProviderType.apple);
      expect(repository.currentUser, isNotNull);

      await repository.logout();

      expect(repository.currentUser, isNull);
    });
  });

  group('AuthController', () {
    test('successful login sets user and clears loading/error', () async {
      final controller = AuthController(
        loginUseCase: LoginWithProviderUseCase(
          AuthRepositoryImpl(_FakeAuthRemoteDataSource()),
        ),
      );

      final user = await controller.loginWithProvider(AuthProviderType.wechat);

      expect(user, isNotNull);
      expect(controller.user, isNotNull);
      expect(controller.isLoading, isFalse);
      expect(controller.errorMessage, isNull);
    });

    test('failed login sets errorMessage and returns null', () async {
      final controller = AuthController(
        loginUseCase: LoginWithProviderUseCase(
          AuthRepositoryImpl(
            _FakeAuthRemoteDataSource(failure: Exception('network down')),
          ),
        ),
      );

      final user = await controller.loginWithProvider(AuthProviderType.google);

      expect(user, isNull);
      expect(controller.errorMessage, isNotNull);
      expect(controller.isLoading, isFalse);
    });
  });
}
