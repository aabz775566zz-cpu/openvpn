import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../vpn/presentation/controllers/vpn_controller.dart';
import '../controllers/auth_controller.dart';
import 'welcome_screen.dart';

/// Initial screen shown while the app performs any startup work
/// (e.g. checking for an existing session). Automatically navigates to
/// [WelcomeScreen] after a short delay.
class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    required this.authController,
    required this.vpnController,
    this.nextScreenBuilder,
  });

  final AuthController authController;
  final VpnController vpnController;

  /// Overridable for testing; defaults to building [WelcomeScreen].
  final WidgetBuilder? nextScreenBuilder;

  static const Duration displayDuration = Duration(milliseconds: 900);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(SplashScreen.displayDuration, _navigateNext);
  }

  void _navigateNext() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: widget.nextScreenBuilder ??
            (_) => WelcomeScreen(
                  authController: widget.authController,
                  vpnController: widget.vpnController,
                ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.vpn_lock_rounded, size: 72),
            const SizedBox(height: 16),
            Text(
              l10n.appTitle,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
