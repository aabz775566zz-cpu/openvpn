/// A VPN server location that a user can connect to.
class VpnServer {
  const VpnServer({
    required this.id,
    required this.name,
    required this.countryCode,
    this.city,
  });

  final String id;
  final String name;

  /// ISO 3166-1 alpha-2 country code, e.g. `US`, `SG`, `JP`.
  final String countryCode;
  final String? city;

  /// A reasonable default server used before the server list has been
  /// fetched from the backend, or if that request fails.
  static const VpnServer auto = VpnServer(
    id: 'auto',
    name: 'Automatic',
    countryCode: 'AUTO',
  );

  factory VpnServer.fromJson(Map<String, dynamic> json) {
    return VpnServer(
      id: json['id'] as String,
      name: json['name'] as String,
      countryCode: json['countryCode'] as String,
      city: json['city'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'countryCode': countryCode,
        if (city != null) 'city': city,
      };

  @override
  bool operator ==(Object other) => other is VpnServer && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
