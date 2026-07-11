import '../../domain/entities/auth_user.dart';

/// Data-layer model mirroring the backend's user representation. Adds
/// JSON (de)serialization on top of the [AuthUser] domain entity.
class AuthUserModel extends AuthUser {
  const AuthUserModel({
    required super.id,
    required super.displayName,
    required super.provider,
    super.email,
    super.avatarUrl,
  });

  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    return AuthUserModel(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
      provider: AuthProviderType.values.byName(json['provider'] as String),
      email: json['email'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'displayName': displayName,
        'provider': provider.name,
        if (email != null) 'email': email,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
      };
}
