import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/vpn_connection_state.dart';
import '../controllers/vpn_controller.dart';

/// Displays detailed VPN connection information: current status, connected
/// duration, and selectable server list.
class VpnScreen extends StatelessWidget {
  const VpnScreen({super.key, required this.controller});

  final VpnController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.vpnScreenTitle)),
      body: ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          final state = controller.connectionState;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _StatusCard(state: state),
              const SizedBox(height: 16),
              Text(
                l10n.serverLocation,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ...controller.servers.map(
                (server) => RadioListTile<String>(
                  value: server.id,
                  groupValue: controller.selectedServer.id,
                  title: Text(server.name),
                  subtitle: Text(server.countryCode),
                  onChanged: state.isTransitioning
                      ? null
                      : (_) => controller.selectServer(server),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed:
                    state.isTransitioning ? null : controller.toggleConnection,
                child: Text(
                  state.isConnected ? l10n.disconnectButton : l10n.connectButton,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.state});

  final VpnConnectionState state;

  String _statusLabel(AppLocalizations l10n) {
    switch (state.status) {
      case VpnConnectionStatus.connected:
        return l10n.connectionStatusConnected;
      case VpnConnectionStatus.connecting:
        return l10n.connectionStatusConnecting;
      case VpnConnectionStatus.disconnecting:
        return l10n.connectionStatusDisconnecting;
      case VpnConnectionStatus.disconnected:
      case VpnConnectionStatus.error:
        return l10n.connectionStatusDisconnected;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final connectedAt = state.connectedAt;
    final elapsed = connectedAt != null
        ? Formatters.duration(DateTime.now().difference(connectedAt))
        : null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _statusLabel(l10n),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            if (elapsed != null) ...[
              const SizedBox(height: 8),
              Text(elapsed, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ],
        ),
      ),
    );
  }
}
