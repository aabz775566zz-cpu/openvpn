import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../vpn/presentation/controllers/vpn_controller.dart';
import '../../../vpn/presentation/screens/vpn_screen.dart';
import '../widgets/connection_status_card.dart';
import '../widgets/server_location_card.dart';

/// The main dashboard screen shown after login: connection status,
/// connect/disconnect action, and the currently selected server location.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.vpnController});

  final VpnController vpnController;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    widget.vpnController.loadServers();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.homeTitle)),
      body: ListenableBuilder(
        listenable: widget.vpnController,
        builder: (context, _) {
          final state = widget.vpnController.connectionState;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ConnectionStatusCard(state: state),
              const SizedBox(height: 12),
              ServerLocationCard(
                server: widget.vpnController.selectedServer,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          VpnScreen(controller: widget.vpnController),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              FilledButton(
                key: const Key('connect_button'),
                onPressed: state.isTransitioning
                    ? null
                    : widget.vpnController.toggleConnection,
                child: Text(
                  state.isConnected
                      ? l10n.disconnectButton
                      : l10n.connectButton,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
