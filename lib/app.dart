import 'package:flutter/material.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/consent_screen.dart';
import 'presentation/screens/dashboard_screen.dart';
import 'presentation/screens/history_screen.dart';
import 'presentation/screens/onboarding_screen.dart';
import 'presentation/screens/presets_screen.dart';

class GpsLocationChangerApp extends StatelessWidget {
  const GpsLocationChangerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routes: {
        '/': (_) => const DashboardScreen(),
        ConsentScreen.routeName: (_) => const ConsentScreen(),
        HistoryScreen.routeName: (_) => const HistoryScreen(),
        OnboardingScreen.routeName: (_) => const OnboardingScreen(),
        PresetsScreen.routeName: (_) => const PresetsScreen(),
      },
    );
  }
}
