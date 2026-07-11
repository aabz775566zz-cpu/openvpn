import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../vpn/domain/entities/vpn_server.dart';

/// Shows the currently selected server location on the home screen.
class ServerLocationCard extends StatelessWidget {
  const ServerLocationCard({
    super.key,
    required this.server,
    this.onTap,
  });

  final VpnServer server;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Card(
      key: const Key('server_location_card'),
      child: ListTile(
        onTap: onTap,
        leading: const Icon(Icons.public_rounded),
        title: Text(l10n.serverLocation),
        subtitle: Text(server.name),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}
