import 'package:flutter/widgets.dart';

/// Supported locales for the OpenWorld VPN application.
class AppLocales {
  const AppLocales._();

  static const Locale english = Locale('en');
  static const Locale chinese = Locale('zh');

  static const List<Locale> supported = [english, chinese];
}

/// A lightweight, dependency-free localization solution.
///
/// This intentionally avoids code-generation tooling (e.g. `intl` ARB
/// codegen) so that the localization layer has no external build step and
/// remains simple to extend as new strings and locales are added.
class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations of(BuildContext context) {
    final localizations =
        Localizations.of<AppLocalizations>(context, AppLocalizations);
    assert(localizations != null, 'No AppLocalizations found in context');
    return localizations!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appTitle': 'OpenWorld VPN',
      'welcomeTitle': 'Welcome to OpenWorld VPN',
      'welcomeSubtitle':
          'Fast, private, and reliable access to the open internet.',
      'getStarted': 'Get Started',
      'loginTitle': 'Sign In',
      'loginSubtitle': 'Choose a sign-in method to continue',
      'continueWithGoogle': 'Continue with Google',
      'continueWithApple': 'Continue with Apple',
      'continueWithWeChat': 'Continue with WeChat',
      'homeTitle': 'Home',
      'connectionStatusConnected': 'Connected',
      'connectionStatusDisconnected': 'Disconnected',
      'connectionStatusConnecting': 'Connecting…',
      'connectionStatusDisconnecting': 'Disconnecting…',
      'connectButton': 'Connect',
      'disconnectButton': 'Disconnect',
      'serverLocation': 'Server Location',
      'vpnScreenTitle': 'VPN',
      'notImplementedYet': '%s sign-in is not yet available',
    },
    'zh': {
      'appTitle': 'OpenWorld VPN',
      'welcomeTitle': '欢迎使用 OpenWorld VPN',
      'welcomeSubtitle': '快速、私密、可靠地访问开放的互联网。',
      'getStarted': '开始使用',
      'loginTitle': '登录',
      'loginSubtitle': '选择一种登录方式以继续',
      'continueWithGoogle': '使用 Google 继续',
      'continueWithApple': '使用 Apple 继续',
      'continueWithWeChat': '使用微信继续',
      'homeTitle': '主页',
      'connectionStatusConnected': '已连接',
      'connectionStatusDisconnected': '未连接',
      'connectionStatusConnecting': '正在连接…',
      'connectionStatusDisconnecting': '正在断开…',
      'connectButton': '连接',
      'disconnectButton': '断开连接',
      'serverLocation': '服务器位置',
      'vpnScreenTitle': 'VPN',
      'notImplementedYet': '%s 登录暂未开放',
    },
  };

  String _value(String key) {
    final languageValues = _localizedValues[locale.languageCode] ??
        _localizedValues[AppLocales.english.languageCode]!;
    return languageValues[key] ?? key;
  }

  String get appTitle => _value('appTitle');
  String get welcomeTitle => _value('welcomeTitle');
  String get welcomeSubtitle => _value('welcomeSubtitle');
  String get getStarted => _value('getStarted');
  String get loginTitle => _value('loginTitle');
  String get loginSubtitle => _value('loginSubtitle');
  String get continueWithGoogle => _value('continueWithGoogle');
  String get continueWithApple => _value('continueWithApple');
  String get continueWithWeChat => _value('continueWithWeChat');
  String get homeTitle => _value('homeTitle');
  String get connectionStatusConnected => _value('connectionStatusConnected');
  String get connectionStatusDisconnected =>
      _value('connectionStatusDisconnected');
  String get connectionStatusConnecting =>
      _value('connectionStatusConnecting');
  String get connectionStatusDisconnecting =>
      _value('connectionStatusDisconnecting');
  String get connectButton => _value('connectButton');
  String get disconnectButton => _value('disconnectButton');
  String get serverLocation => _value('serverLocation');
  String get vpnScreenTitle => _value('vpnScreenTitle');

  /// Returns a localized "not implemented" message for a given provider
  /// name, e.g. `notImplementedFor('Google')`.
  String notImplementedFor(String providerName) =>
      _value('notImplementedYet').replaceAll('%s', providerName);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      AppLocales.supported.any((l) => l.languageCode == locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
