import 'package:flutter_test/flutter_test.dart';
import 'package:openworld_vpn_mobile/features/vpn/domain/entities/vpn_connection_state.dart';

void main() {
  group('VpnConnectionState', () {
    test('initial state is disconnected with no metadata', () {
      const state = VpnConnectionState.initial();
      expect(state.status, VpnConnectionStatus.disconnected);
      expect(state.isConnected, isFalse);
      expect(state.isTransitioning, isFalse);
      expect(state.serverId, isNull);
      expect(state.connectedAt, isNull);
    });

    test('isConnected is true only when status is connected', () {
      const connected = VpnConnectionState(status: VpnConnectionStatus.connected);
      const connecting = VpnConnectionState(status: VpnConnectionStatus.connecting);
      expect(connected.isConnected, isTrue);
      expect(connecting.isConnected, isFalse);
    });

    test('isTransitioning is true for connecting/disconnecting', () {
      const connecting = VpnConnectionState(status: VpnConnectionStatus.connecting);
      const disconnecting =
          VpnConnectionState(status: VpnConnectionStatus.disconnecting);
      const connected = VpnConnectionState(status: VpnConnectionStatus.connected);

      expect(connecting.isTransitioning, isTrue);
      expect(disconnecting.isTransitioning, isTrue);
      expect(connected.isTransitioning, isFalse);
    });

    test('copyWith updates only provided fields', () {
      const initial = VpnConnectionState.initial();
      final updated = initial.copyWith(
        status: VpnConnectionStatus.connecting,
        serverId: 'server-1',
      );

      expect(updated.status, VpnConnectionStatus.connecting);
      expect(updated.serverId, 'server-1');
      expect(updated.connectedAt, isNull);
    });

    test('copyWith can clear connectedAt and errorMessage', () {
      final state = VpnConnectionState(
        status: VpnConnectionStatus.connected,
        connectedAt: DateTime(2024, 1, 1),
        errorMessage: 'boom',
      );

      final cleared = state.copyWith(clearConnectedAt: true, clearError: true);

      expect(cleared.connectedAt, isNull);
      expect(cleared.errorMessage, isNull);
    });

    test('equality is based on field values', () {
      final a = VpnConnectionState(
        status: VpnConnectionStatus.connected,
        serverId: 'server-1',
      );
      final b = VpnConnectionState(
        status: VpnConnectionStatus.connected,
        serverId: 'server-1',
      );
      expect(a, equals(b));
    });
  });
}
