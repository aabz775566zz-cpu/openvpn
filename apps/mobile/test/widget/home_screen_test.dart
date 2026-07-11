import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openworld_vpn_mobile/core/localization/app_localizations.dart';
import 'package:openworld_vpn_mobile/features/home/presentation/screens/home_screen.dart';
import 'package:openworld_vpn_mobile/features/home/presentation/widgets/connection_status_card.dart';
import 'package:openworld_vpn_mobile/features/home/presentation/widgets/server_location_card.dart';
import 'package:openworld_vpn_mobile/features/vpn/data/services/placeholder_vpn_service.dart';
import 'package:openworld_vpn_mobile/features/vpn/domain/entities/vpn_server.dart';
import 'package:openworld_vpn_mobile/features/vpn/domain/repositories/vpn_server_repository.dart';
import 'package:openworld_vpn_mobile/features/vpn/presentation/controllers/vpn_controller.dart';

import 'test_helpers.dart';

class _FakeServerRepository implements VpnServerRepository {
  @override
  Future<List<VpnServer>> fetchServers() async => const [VpnServer.auto];
}

VpnController _buildVpnController({Duration connectDelay = Duration.zero}) {
  return VpnController(
    vpnService: PlaceholderVpnService(connectDelay: connectDelay),
    serverRepository: _FakeServerRepository(),
  );
}

void main() {
  testWidgets('HomeScreen shows connection status, server card and connect button',
      (tester) async {
    final controller = _buildVpnController();
    await tester.pumpWidget(wrapWithApp(HomeScreen(vpnController: controller)));
    await tester.pumpAndSettle();

    expect(find.byType(ConnectionStatusCard), findsOneWidget);
    expect(find.byType(ServerLocationCard), findsOneWidget);
    expect(find.byKey(const Key('connect_button')), findsOneWidget);

    final context = tester.element(find.byType(HomeScreen));
    final l10n = AppLocalizations.of(context);
    expect(find.text(l10n.connectionStatusDisconnected), findsOneWidget);
  });

  testWidgets('Tapping connect transitions status to connected', (tester) async {
    final controller = _buildVpnController();
    await tester.pumpWidget(wrapWithApp(HomeScreen(vpnController: controller)));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('connect_button')));
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(HomeScreen));
    final l10n = AppLocalizations.of(context);
    expect(find.text(l10n.connectionStatusConnected), findsOneWidget);
    expect(find.text(l10n.disconnectButton), findsOneWidget);
  });
}
