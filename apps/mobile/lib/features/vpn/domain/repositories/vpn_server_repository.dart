import '../entities/vpn_server.dart';

/// Repository abstraction for retrieving available VPN server locations.
abstract class VpnServerRepository {
  Future<List<VpnServer>> fetchServers();
}
