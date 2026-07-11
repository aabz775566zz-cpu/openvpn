import 'package:flutter_test/flutter_test.dart';
import 'package:openworld_vpn_mobile/features/vpn/data/services/placeholder_vpn_service.dart';
import 'package:openworld_vpn_mobile/features/vpn/domain/entities/vpn_connection_state.dart';
import 'package:openworld_vpn_mobile/features/vpn/domain/entities/vpn_server.dart';

void main() {
  group('PlaceholderVpnService', () {
    test('starts in the disconnected state', () {
      final service = PlaceholderVpnService();
      expect(service.currentState.status, VpnConnectionStatus.disconnected);
      service.dispose();
    });

    test('connect() transitions through connecting to connected', () async {
      final service = PlaceholderVpnService(
        connectDelay: Duration.zero,
        disconnectDelay: Duration.zero,
      );
      final states = <VpnConnectionStatus>[];
      final sub = service.connectionStateStream.listen((s) => states.add(s.status));

      await service.connect(VpnServer.auto);
      await Future<void>.delayed(Duration.zero);

      expect(states, [VpnConnectionStatus.connecting, VpnConnectionStatus.connected]);
      expect(service.currentState.isConnected, isTrue);
      expect(service.currentState.serverId, VpnServer.auto.id);

      await sub.cancel();
      service.dispose();
    });

    test('disconnect() transitions through disconnecting to disconnected', () async {
      final service = PlaceholderVpnService(
        connectDelay: Duration.zero,
        disconnectDelay: Duration.zero,
      );

      await service.connect(VpnServer.auto);
      final states = <VpnConnectionStatus>[];
      final sub = service.connectionStateStream.listen((s) => states.add(s.status));

      await service.disconnect();

      expect(
        states,
        [VpnConnectionStatus.disconnecting, VpnConnectionStatus.disconnected],
      );
      expect(service.currentState.isConnected, isFalse);
      expect(service.currentState.connectedAt, isNull);

      await sub.cancel();
      service.dispose();
    });

    test('connect() is a no-op while already connecting/connected', () async {
      final service = PlaceholderVpnService(
        connectDelay: const Duration(milliseconds: 50),
      );

      final firstConnect = service.connect(VpnServer.auto);
      final secondConnect = service.connect(VpnServer.auto);

      await Future.wait([firstConnect, secondConnect]);

      expect(service.currentState.isConnected, isTrue);
      service.dispose();
    });
  });
}
