import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openworld_vpn_mobile/core/localization/app_localizations.dart';
import 'package:openworld_vpn_mobile/core/theme/app_theme.dart';

/// Wraps [child] with the MaterialApp + localization scaffolding needed by
/// most screens under test.
Widget wrapWithApp(Widget child) {
  return MaterialApp(
    theme: AppTheme.light,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocales.supported,
    home: child,
  );
}
