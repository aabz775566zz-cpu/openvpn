import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openworld_vpn_mobile/core/localization/app_localizations.dart';
import 'package:openworld_vpn_mobile/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:openworld_vpn_mobile/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:openworld_vpn_mobile/features/auth/domain/usecases/login_with_provider_usecase.dart';
import 'package:openworld_vpn_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:openworld_vpn_mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:openworld_vpn_mobile/features/auth/presentation/screens/welcome_screen.dart';
import 'package:openworld_vpn_mobile/features/vpn/data/services/placeholder_vpn_service.dart';
import 'package:openworld_vpn_mobile/features/vpn/domain/entities/vpn_server.dart';
import 'package:openworld_vpn_mobile/features/vpn/domain/repositories/vpn_server_repository.dart';
import 'package:openworld_vpn_mobile/features/vpn/presentation/controllers/vpn_controller.dart';

import 'test_helpers.dart';

class _FakeServerRepository implements VpnServerRepository {
  @override
  Future<List<VpnServer>> fetchServers() async => const [VpnServer.auto];
}

AuthController _buildAuthController() {
  return AuthController(
    loginUseCase: LoginWithProviderUseCase(
      AuthRepositoryImpl(PlaceholderAuthRemoteDataSource()),
    ),
  );
}

VpnController _buildVpnController() {
  return VpnController(
    vpnService: PlaceholderVpnService(),
    serverRepository: _FakeServerRepository(),
  );
}

void main() {
  testWidgets('WelcomeScreen shows title, subtitle and Get Started button',
      (tester) async {
    await tester.pumpWidget(wrapWithApp(
      WelcomeScreen(
        authController: _buildAuthController(),
        vpnController: _buildVpnController(),
      ),
    ));

    final context = tester.element(find.byType(WelcomeScreen));
    final l10n = AppLocalizations.of(context);

    expect(find.text(l10n.welcomeTitle), findsOneWidget);
    expect(find.text(l10n.welcomeSubtitle), findsOneWidget);
    expect(find.widgetWithText(FilledButton, l10n.getStarted), findsOneWidget);
  });

  testWidgets('Tapping Get Started navigates to the LoginScreen', (tester) async {
    await tester.pumpWidget(wrapWithApp(
      WelcomeScreen(
        authController: _buildAuthController(),
        vpnController: _buildVpnController(),
      ),
    ));

    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
  });
}
