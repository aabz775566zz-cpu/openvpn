import '../../domain/entities/vpn_server.dart';
import '../../domain/repositories/vpn_server_repository.dart';
import '../datasources/server_remote_data_source.dart';

/// Default [VpnServerRepository] implementation.
///
/// Falls back to [VpnServer.auto] if the backend request fails, so the UI
/// always has a sensible server to display even before real backend
/// integration is wired up end-to-end.
class VpnServerRepositoryImpl implements VpnServerRepository {
  VpnServerRepositoryImpl(this._remoteDataSource);

  final ServerRemoteDataSource _remoteDataSource;

  @override
  Future<List<VpnServer>> fetchServers() async {
    try {
      final servers = await _remoteDataSource.fetchServers();
      return servers.isEmpty ? const [VpnServer.auto] : servers;
    } catch (_) {
      return const [VpnServer.auto];
    }
  }
}
