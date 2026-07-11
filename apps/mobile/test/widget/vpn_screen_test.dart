import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openworld_vpn_mobile/core/localization/app_localizations.dart';
import 'package:openworld_vpn_mobile/features/vpn/data/services/placeholder_vpn_service.dart';
import 'package:openworld_vpn_mobile/features/vpn/domain/entities/vpn_server.dart';
import 'package:openworld_vpn_mobile/features/vpn/domain/repositories/vpn_server_repository.dart';
import 'package:openworld_vpn_mobile/features/vpn/presentation/controllers/vpn_controller.dart';
import 'package:openworld_vpn_mobile/features/vpn/presentation/screens/vpn_screen.dart';

import 'test_helpers.dart';

const _serverA = VpnServer(id: 'a', name: 'Server A', countryCode: 'US');
const _serverB = VpnServer(id: 'b', name: 'Server B', countryCode: 'SG');

class _FakeServerRepository implements VpnServerRepository {
  @override
  Future<List<VpnServer>> fetchServers() async => const [_serverA, _serverB];
}

void main() {
  testWidgets('VpnScreen lists servers and allows selection', (tester) async {
    final controller = VpnController(
      vpnService: PlaceholderVpnService(),
      serverRepository: _FakeServerRepository(),
    );
    await controller.loadServers();

    await tester.pumpWidget(wrapWithApp(VpnScreen(controller: controller)));
    await tester.pumpAndSettle();

    expect(find.text('Server A'), findsOneWidget);
    expect(find.text('Server B'), findsOneWidget);

    await tester.tap(find.text('Server B'));
    await tester.pumpAndSettle();

    expect(controller.selectedServer, _serverB);
  });

  testWidgets('VpnScreen connect button toggles connection state', (tester) async {
    final controller = VpnController(
      vpnService: PlaceholderVpnService(connectDelay: Duration.zero),
      serverRepository: _FakeServerRepository(),
    );
    await controller.loadServers();

    await tester.pumpWidget(wrapWithApp(VpnScreen(controller: controller)));
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(VpnScreen));
    final l10n = AppLocalizations.of(context);

    expect(find.widgetWithText(FilledButton, l10n.connectButton), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, l10n.connectButton));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(FilledButton, l10n.disconnectButton), findsOneWidget);
  });
}
