import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../vpn/domain/entities/vpn_connection_state.dart';

/// Displays the current VPN connection status prominently on the home
/// screen.
class ConnectionStatusCard extends StatelessWidget {
  const ConnectionStatusCard({super.key, required this.state});

  final VpnConnectionState state;

  String _label(AppLocalizations l10n) {
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

  Color _color(ColorScheme scheme) {
    switch (state.status) {
      case VpnConnectionStatus.connected:
        return scheme.primary;
      case VpnConnectionStatus.error:
        return scheme.error;
      case VpnConnectionStatus.connecting:
      case VpnConnectionStatus.disconnecting:
      case VpnConnectionStatus.disconnected:
        return scheme.onSurfaceVariant;
    }
  }

  IconData get _icon {
    switch (state.status) {
      case VpnConnectionStatus.connected:
        return Icons.shield_rounded;
      case VpnConnectionStatus.error:
        return Icons.error_rounded;
      case VpnConnectionStatus.connecting:
      case VpnConnectionStatus.disconnecting:
        return Icons.sync_rounded;
      case VpnConnectionStatus.disconnected:
        return Icons.shield_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Card(
      key: const Key('connection_status_card'),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Icon(_icon, size: 40, color: _color(scheme)),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                _label(l10n),
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(color: _color(scheme)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
