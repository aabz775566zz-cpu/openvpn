import 'package:flutter_test/flutter_test.dart';
import 'package:openworld_vpn_mobile/features/vpn/data/services/placeholder_vpn_service.dart';
import 'package:openworld_vpn_mobile/features/vpn/domain/entities/vpn_server.dart';
import 'package:openworld_vpn_mobile/features/vpn/domain/repositories/vpn_server_repository.dart';
import 'package:openworld_vpn_mobile/features/vpn/presentation/controllers/vpn_controller.dart';

class _FakeVpnServerRepository implements VpnServerRepository {
  _FakeVpnServerRepository(this._servers);

  final List<VpnServer> _servers;

  @override
  Future<List<VpnServer>> fetchServers() async => _servers;
}

const _serverA = VpnServer(id: 'a', name: 'Server A', countryCode: 'US');
const _serverB = VpnServer(id: 'b', name: 'Server B', countryCode: 'SG');

void main() {
  group('VpnController', () {
    test('loadServers populates the server list and selects the first', () async {
      final controller = VpnController(
        vpnService: PlaceholderVpnService(),
        serverRepository: _FakeVpnServerRepository([_serverA, _serverB]),
      );

      await controller.loadServers();

      expect(controller.servers, [_serverA, _serverB]);
      expect(controller.selectedServer, _serverA);
      expect(controller.isLoadingServers, isFalse);

      controller.dispose();
    });

    test('selectServer updates the selected server and notifies listeners', () async {
      final controller = VpnController(
        vpnService: PlaceholderVpnService(),
        serverRepository: _FakeVpnServerRepository([_serverA, _serverB]),
      );
      await controller.loadServers();

      var notified = false;
      controller.addListener(() => notified = true);
      controller.selectServer(_serverB);

      expect(controller.selectedServer, _serverB);
      expect(notified, isTrue);

      controller.dispose();
    });

    test('toggleConnection connects then disconnects', () async {
      final controller = VpnController(
        vpnService: PlaceholderVpnService(
          connectDelay: Duration.zero,
          disconnectDelay: Duration.zero,
        ),
        serverRepository: _FakeVpnServerRepository([_serverA]),
      );

      await controller.toggleConnection();
      expect(controller.connectionState.isConnected, isTrue);

      await controller.toggleConnection();
      expect(controller.connectionState.isConnected, isFalse);

      controller.dispose();
    });

    test('falls back to VpnServer.auto when repository returns nothing', () async {
      final controller = VpnController(
        vpnService: PlaceholderVpnService(),
        serverRepository: _FakeVpnServerRepository(const []),
      );

      await controller.loadServers();

      expect(controller.servers, [VpnServer.auto]);

      controller.dispose();
    });
  });
}
