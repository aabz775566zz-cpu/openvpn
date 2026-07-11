/// High-level connection lifecycle status for the placeholder VPN service.
enum VpnConnectionStatus {
  disconnected,
  connecting,
  connected,
  disconnecting,
  error,
}

/// Immutable snapshot of the current VPN connection state.
///
/// This is a pure data model (no platform/tunnel logic) so it can be used
/// freely by presentation-layer widgets and unit tested in isolation.
class VpnConnectionState {
  const VpnConnectionState({
    required this.status,
    this.serverId,
    this.connectedAt,
    this.errorMessage,
  });

  const VpnConnectionState.initial()
      : status = VpnConnectionStatus.disconnected,
        serverId = null,
        connectedAt = null,
        errorMessage = null;

  final VpnConnectionStatus status;

  /// The id of the server the client is connected/connecting to, if any.
  final String? serverId;

  /// Timestamp of when the connection became active, used to compute
  /// elapsed connected time in the UI.
  final DateTime? connectedAt;

  /// Populated when [status] is [VpnConnectionStatus.error].
  final String? errorMessage;

  bool get isConnected => status == VpnConnectionStatus.connected;
  bool get isTransitioning =>
      status == VpnConnectionStatus.connecting ||
      status == VpnConnectionStatus.disconnecting;

  VpnConnectionState copyWith({
    VpnConnectionStatus? status,
    String? serverId,
    DateTime? connectedAt,
    String? errorMessage,
    bool clearError = false,
    bool clearConnectedAt = false,
  }) {
    return VpnConnectionState(
      status: status ?? this.status,
      serverId: serverId ?? this.serverId,
      connectedAt:
          clearConnectedAt ? null : (connectedAt ?? this.connectedAt),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is VpnConnectionState &&
        other.status == status &&
        other.serverId == serverId &&
        other.connectedAt == connectedAt &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode => Object.hash(status, serverId, connectedAt, errorMessage);

  @override
  String toString() =>
      'VpnConnectionState(status: $status, serverId: $serverId)';
}
