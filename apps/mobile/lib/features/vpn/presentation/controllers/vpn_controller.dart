import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../domain/entities/vpn_connection_state.dart';
import '../../domain/entities/vpn_server.dart';
import '../../domain/repositories/vpn_server_repository.dart';
import '../../domain/services/vpn_service.dart';

/// Presentation-layer controller that exposes VPN connection state and
/// available servers to the widget tree.
///
/// Uses plain [ChangeNotifier] + [ListenableBuilder]/[AnimatedBuilder] so no
/// extra state-management package is required.
class VpnController extends ChangeNotifier {
  VpnController({
    required VpnService vpnService,
    required VpnServerRepository serverRepository,
  })  : _vpnService = vpnService,
        _serverRepository = serverRepository {
    _subscription = _vpnService.connectionStateStream.listen((_) {
      notifyListeners();
    });
  }

  final VpnService _vpnService;
  final VpnServerRepository _serverRepository;
  late final StreamSubscription<VpnConnectionState> _subscription;

  List<VpnServer> _servers = const [VpnServer.auto];
  VpnServer _selectedServer = VpnServer.auto;
  bool _isLoadingServers = false;

  VpnConnectionState get connectionState => _vpnService.currentState;
  List<VpnServer> get servers => List.unmodifiable(_servers);
  VpnServer get selectedServer => _selectedServer;
  bool get isLoadingServers => _isLoadingServers;

  Future<void> loadServers() async {
    _isLoadingServers = true;
    notifyListeners();
    try {
      final servers = await _serverRepository.fetchServers();
      _servers = servers.isEmpty ? const [VpnServer.auto] : servers;
      if (!_servers.contains(_selectedServer)) {
        _selectedServer = _servers.first;
      }
    } finally {
      _isLoadingServers = false;
      notifyListeners();
    }
  }

  void selectServer(VpnServer server) {
    _selectedServer = server;
    notifyListeners();
  }

  Future<void> toggleConnection() async {
    if (connectionState.isConnected) {
      await _vpnService.disconnect();
    } else if (!connectionState.isTransitioning) {
      await _vpnService.connect(_selectedServer);
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    _vpnService.dispose();
    super.dispose();
  }
}
