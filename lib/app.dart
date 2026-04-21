import 'package:flutter/material.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/consent_screen.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/settings_screen.dart';

class GpsLocationChangerApp extends StatelessWidget {
  const GpsLocationChangerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      routes: {
        '/': (_) => const HomeScreen(),
        ConsentScreen.routeName: (_) => const ConsentScreen(),
        SettingsScreen.routeName: (_) => const SettingsScreen(),
      },
    );
  }
}
