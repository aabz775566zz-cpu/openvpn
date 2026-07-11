import '../../../../core/network/api_client.dart';
import '../../domain/entities/vpn_server.dart';

/// Fetches available VPN server locations from the backend REST API.
///
/// Backed by the [ApiClient] foundation. The concrete endpoint
/// (`/api/v1/vpn/servers`) mirrors the backend route convention documented
/// in `backend/src/routes/v1/index.ts`.
class ServerRemoteDataSource {
  ServerRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<List<VpnServer>> fetchServers() async {
    final response = await _apiClient.get('/api/v1/vpn/servers');
    final data = response['data'];
    if (data is! List) {
      return const [];
    }
    return data
        .whereType<Map<String, dynamic>>()
        .map(VpnServer.fromJson)
        .toList(growable: false);
  }
}
