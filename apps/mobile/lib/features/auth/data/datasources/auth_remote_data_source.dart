import '../../domain/entities/auth_user.dart';
import '../models/auth_user_model.dart';

/// Placeholder authentication data source.
///
/// No real OAuth credentials or backend calls are wired up yet — this
/// simulates a successful sign-in after a short delay so the presentation
/// layer and navigation flow can be built and tested end-to-end. A future
/// phase will replace this with real Google/Apple/WeChat SDK integrations
/// and a call through [ApiClient] to exchange the provider token for a
/// backend session.
abstract class AuthRemoteDataSource {
  Future<AuthUserModel> loginWithProvider(AuthProviderType provider);
}

class PlaceholderAuthRemoteDataSource implements AuthRemoteDataSource {
  PlaceholderAuthRemoteDataSource({
    this.simulatedDelay = const Duration(milliseconds: 600),
  });

  final Duration simulatedDelay;

  @override
  Future<AuthUserModel> loginWithProvider(AuthProviderType provider) async {
    await Future<void>.delayed(simulatedDelay);
    return AuthUserModel(
      id: 'placeholder-${provider.name}-user',
      displayName: 'OpenWorld User',
      provider: provider,
    );
  }
}
