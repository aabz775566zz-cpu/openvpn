import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openworld_vpn_mobile/core/localization/app_localizations.dart';
import 'package:openworld_vpn_mobile/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:openworld_vpn_mobile/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:openworld_vpn_mobile/features/auth/domain/usecases/login_with_provider_usecase.dart';
import 'package:openworld_vpn_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:openworld_vpn_mobile/features/auth/presentation/screens/splash_screen.dart';
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
  testWidgets('SplashScreen shows the app title and a loading indicator', (tester) async {
    await tester.pumpWidget(wrapWithApp(
      SplashScreen(
        authController: _buildAuthController(),
        vpnController: _buildVpnController(),
        nextScreenBuilder: (_) => const SizedBox.shrink(),
      ),
    ));

    final context = tester.element(find.byType(SplashScreen));
    final l10n = AppLocalizations.of(context);

    expect(find.text(l10n.appTitle), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('SplashScreen navigates to the next screen after its display duration',
      (tester) async {
    await tester.pumpWidget(wrapWithApp(
      SplashScreen(
        authController: _buildAuthController(),
        vpnController: _buildVpnController(),
        nextScreenBuilder: (_) => const Scaffold(body: Text('NEXT_SCREEN')),
      ),
    ));

    await tester.pump(SplashScreen.displayDuration + const Duration(milliseconds: 50));
    await tester.pumpAndSettle();

    expect(find.text('NEXT_SCREEN'), findsOneWidget);
  });
}
