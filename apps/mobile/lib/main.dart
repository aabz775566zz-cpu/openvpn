import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/localization/app_localizations.dart';
import 'core/network/api_client.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/usecases/login_with_provider_usecase.dart';
import 'features/auth/presentation/controllers/auth_controller.dart';
import 'features/auth/presentation/screens/splash_screen.dart';
import 'features/vpn/data/datasources/server_remote_data_source.dart';
import 'features/vpn/data/repositories/vpn_server_repository_impl.dart';
import 'features/vpn/data/services/placeholder_vpn_service.dart';
import 'features/vpn/presentation/controllers/vpn_controller.dart';

/// Backend base URL. This is a placeholder pointing at the OpenWorld VPN
/// API; no live endpoint is assumed to be reachable at this phase.
const String kApiBaseUrl = 'https://api.openworldvpn.dev';

void main() {
  runApp(OpenWorldVpnApp(dependencies: AppDependencies.create()));
}

/// Composition root: wires together the concrete implementations behind
/// each feature's domain interfaces. Kept intentionally simple (no DI
/// framework) given the scope of this phase.
class AppDependencies {
  AppDependencies({
    required this.authController,
    required this.vpnController,
  });

  factory AppDependencies.create() {
    final apiClient = ApiClient(baseUrl: kApiBaseUrl);

    final vpnController = VpnController(
      vpnService: PlaceholderVpnService(),
      serverRepository:
          VpnServerRepositoryImpl(ServerRemoteDataSource(apiClient)),
    );

    final authController = AuthController(
      loginUseCase: LoginWithProviderUseCase(
        AuthRepositoryImpl(PlaceholderAuthRemoteDataSource()),
      ),
    );

    return AppDependencies(
      authController: authController,
      vpnController: vpnController,
    );
  }

  final AuthController authController;
  final VpnController vpnController;
}

/// Root widget performing Material 3 app initialization: theme,
/// localization, and the initial route (splash screen).
class OpenWorldVpnApp extends StatelessWidget {
  const OpenWorldVpnApp({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocales.supported,
      home: SplashScreen(
        authController: dependencies.authController,
        vpnController: dependencies.vpnController,
      ),
    );
  }
}
