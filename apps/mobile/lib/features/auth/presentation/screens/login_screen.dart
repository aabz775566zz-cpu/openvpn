import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../home/presentation/screens/home_screen.dart';
import '../../../vpn/presentation/controllers/vpn_controller.dart';
import '../../domain/entities/auth_user.dart';
import '../controllers/auth_controller.dart';
import '../widgets/social_login_button.dart';

/// Sign-in screen offering placeholder social login options. No real OAuth
/// SDK is integrated; each button drives [AuthController]'s simulated
/// login flow and navigates to [HomeScreen] on (simulated) success.
class LoginScreen extends StatelessWidget {
  const LoginScreen({
    super.key,
    required this.authController,
    required this.vpnController,
  });

  final AuthController authController;
  final VpnController vpnController;

  Future<void> _handleLogin(
    BuildContext context,
    AuthProviderType provider,
  ) async {
    final user = await authController.loginWithProvider(provider);
    if (!context.mounted) return;

    if (user != null) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => HomeScreen(vpnController: vpnController),
        ),
        (route) => false,
      );
    } else if (authController.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authController.errorMessage!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.loginTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ListenableBuilder(
            listenable: authController,
            builder: (context, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.loginSubtitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 32),
                  if (authController.isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  SocialLoginButton(
                    provider: AuthProviderType.google,
                    label: l10n.continueWithGoogle,
                    icon: Icons.g_mobiledata_rounded,
                    onPressed: authController.isLoading
                        ? () {}
                        : () => _handleLogin(context, AuthProviderType.google),
                  ),
                  const SizedBox(height: 12),
                  SocialLoginButton(
                    provider: AuthProviderType.apple,
                    label: l10n.continueWithApple,
                    icon: Icons.apple_rounded,
                    onPressed: authController.isLoading
                        ? () {}
                        : () => _handleLogin(context, AuthProviderType.apple),
                  ),
                  const SizedBox(height: 12),
                  SocialLoginButton(
                    provider: AuthProviderType.wechat,
                    label: l10n.continueWithWeChat,
                    icon: Icons.chat_bubble_rounded,
                    onPressed: authController.isLoading
                        ? () {}
                        : () => _handleLogin(context, AuthProviderType.wechat),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
