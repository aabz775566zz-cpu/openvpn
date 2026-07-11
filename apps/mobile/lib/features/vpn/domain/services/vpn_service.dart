import '../entities/vpn_connection_state.dart';
import '../entities/vpn_server.dart';

/// Domain-level abstraction for the VPN connection engine.
///
/// This interface deliberately says nothing about *how* a tunnel is
/// established (WireGuard, platform VPN APIs, etc.). Phase 4 ships only a
/// placeholder implementation ([PlaceholderVpnService]); a real
/// implementation will be provided in a later phase without requiring any
/// change to feature/presentation code that depends on this interface.
abstract class VpnService {
  /// Emits the current connection state whenever it changes.
  Stream<VpnConnectionState> get connectionStateStream;

  /// The most recently known connection state.
  VpnConnectionState get currentState;

  /// Requests a connection to [server]. Completes once the connection
  /// attempt has settled (either connected or failed).
  Future<void> connect(VpnServer server);

  /// Requests disconnection from the current server. Completes once
  /// disconnection has settled.
  Future<void> disconnect();

  /// Releases any resources held by the service.
  void dispose();
}
