import 'package:flutter/material.dart';

import '../../domain/entities/auth_user.dart';

/// A placeholder social sign-in button. No real OAuth SDK is integrated
/// yet; [onPressed] is expected to be wired to a placeholder handler (e.g.
/// showing a "coming soon" message) until real provider integration lands.
class SocialLoginButton extends StatelessWidget {
  const SocialLoginButton({
    super.key,
    required this.provider,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final AuthProviderType provider;
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      key: Key('social_login_button_${provider.name}'),
      onPressed: onPressed,
      icon: Icon(icon),
      label: Align(
        alignment: Alignment.center,
        child: Text(label),
      ),
    );
  }
}
