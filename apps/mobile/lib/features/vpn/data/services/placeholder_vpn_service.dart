import 'dart:async';

import '../../domain/entities/vpn_connection_state.dart';
import '../../domain/entities/vpn_server.dart';
import '../../domain/services/vpn_service.dart';

/// A placeholder [VpnService] implementation.
///
/// This simulates connect/disconnect state transitions with short delays so
/// that the UI and presentation logic can be built and tested end-to-end.
/// **It does not open any real network tunnel.** A future phase will
/// replace this with a WireGuard-backed implementation behind the same
/// [VpnService] interface.
class PlaceholderVpnService implements VpnService {
  PlaceholderVpnService({
    this.connectDelay = const Duration(milliseconds: 800),
    this.disconnectDelay = const Duration(milliseconds: 400),
  }) {
    _controller = StreamController<VpnConnectionState>.broadcast();
  }

  final Duration connectDelay;
  final Duration disconnectDelay;

  late final StreamController<VpnConnectionState> _controller;
  VpnConnectionState _state = const VpnConnectionState.initial();

  @override
  Stream<VpnConnectionState> get connectionStateStream => _controller.stream;

  @override
  VpnConnectionState get currentState => _state;

  void _emit(VpnConnectionState state) {
    _state = state;
    if (!_controller.isClosed) {
      _controller.add(state);
    }
  }

  @override
  Future<void> connect(VpnServer server) async {
    if (_state.status == VpnConnectionStatus.connecting ||
        _state.status == VpnConnectionStatus.connected) {
      return;
    }

    _emit(_state.copyWith(
      status: VpnConnectionStatus.connecting,
      serverId: server.id,
      clearError: true,
    ));

    await Future<void>.delayed(connectDelay);

    _emit(_state.copyWith(
      status: VpnConnectionStatus.connected,
      serverId: server.id,
      connectedAt: DateTime.now(),
    ));
  }

  @override
  Future<void> disconnect() async {
    if (_state.status == VpnConnectionStatus.disconnected ||
        _state.status == VpnConnectionStatus.disconnecting) {
      return;
    }

    _emit(_state.copyWith(status: VpnConnectionStatus.disconnecting));

    await Future<void>.delayed(disconnectDelay);

    _emit(_state.copyWith(
      status: VpnConnectionStatus.disconnected,
      clearConnectedAt: true,
    ));
  }

  @override
  void dispose() {
    _controller.close();
  }
}
