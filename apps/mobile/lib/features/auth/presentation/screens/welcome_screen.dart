import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../vpn/presentation/controllers/vpn_controller.dart';
import '../controllers/auth_controller.dart';
import 'login_screen.dart';

/// First screen a user sees (after splash) introducing the product before
/// prompting them to sign in.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({
    super.key,
    required this.authController,
    required this.vpnController,
  });

  final AuthController authController;
  final VpnController vpnController;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.public_rounded, size: 96),
              const SizedBox(height: 32),
              Text(
                l10n.welcomeTitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.welcomeSubtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 40),
              FilledButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => LoginScreen(
                        authController: authController,
                        vpnController: vpnController,
                      ),
                    ),
                  );
                },
                child: Text(l10n.getStarted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
