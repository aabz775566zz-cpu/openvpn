/// Supported social sign-in providers (all placeholder / no real OAuth
/// credentials are wired up yet).
enum AuthProviderType { google, apple, wechat }

/// An authenticated user, as understood by the app.
class AuthUser {
  const AuthUser({
    required this.id,
    required this.displayName,
    required this.provider,
    this.email,
    this.avatarUrl,
  });

  final String id;
  final String displayName;
  final AuthProviderType provider;
  final String? email;
  final String? avatarUrl;
}
