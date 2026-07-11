import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openworld_vpn_mobile/core/localization/app_localizations.dart';
import 'package:openworld_vpn_mobile/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:openworld_vpn_mobile/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:openworld_vpn_mobile/features/auth/domain/usecases/login_with_provider_usecase.dart';
import 'package:openworld_vpn_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:openworld_vpn_mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:openworld_vpn_mobile/features/auth/presentation/widgets/social_login_button.dart';
import 'package:openworld_vpn_mobile/features/home/presentation/screens/home_screen.dart';
import 'package:openworld_vpn_mobile/features/vpn/data/services/placeholder_vpn_service.dart';
import 'package:openworld_vpn_mobile/features/vpn/domain/entities/vpn_server.dart';
import 'package:openworld_vpn_mobile/features/vpn/domain/repositories/vpn_server_repository.dart';
import 'package:openworld_vpn_mobile/features/vpn/presentation/controllers/vpn_controller.dart';

import 'test_helpers.dart';

class _FakeServerRepository implements VpnServerRepository {
  @override
  Future<List<VpnServer>> fetchServers() async => const [VpnServer.auto];
}

VpnController _buildVpnController() {
  return VpnController(
    vpnService: PlaceholderVpnService(connectDelay: Duration.zero),
    serverRepository: _FakeServerRepository(),
  );
}

void main() {
  testWidgets('LoginScreen shows all three placeholder social login buttons',
      (tester) async {
    final authController = AuthController(
      loginUseCase: LoginWithProviderUseCase(
        AuthRepositoryImpl(
          PlaceholderAuthRemoteDataSource(simulatedDelay: Duration.zero),
        ),
      ),
    );

    await tester.pumpWidget(wrapWithApp(
      LoginScreen(
        authController: authController,
        vpnController: _buildVpnController(),
      ),
    ));

    final context = tester.element(find.byType(LoginScreen));
    final l10n = AppLocalizations.of(context);

    expect(find.text(l10n.continueWithGoogle), findsOneWidget);
    expect(find.text(l10n.continueWithApple), findsOneWidget);
    expect(find.text(l10n.continueWithWeChat), findsOneWidget);
    expect(find.byType(SocialLoginButton), findsNWidgets(3));
  });

  testWidgets('Tapping the Google button logs in and navigates to HomeScreen',
      (tester) async {
    final authController = AuthController(
      loginUseCase: LoginWithProviderUseCase(
        AuthRepositoryImpl(
          PlaceholderAuthRemoteDataSource(simulatedDelay: Duration.zero),
        ),
      ),
    );

    await tester.pumpWidget(wrapWithApp(
      LoginScreen(
        authController: authController,
        vpnController: _buildVpnController(),
      ),
    ));

    await tester.tap(find.byKey(const Key('social_login_button_google')));
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
