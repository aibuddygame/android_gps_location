import 'package:flutter/material.dart';

import 'core/constants/app_constants.dart';
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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0B7A75),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size(96, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        cardTheme: CardThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      routes: {
        '/': (_) => const DashboardScreen(),
        HistoryScreen.routeName: (_) => const HistoryScreen(),
        OnboardingScreen.routeName: (_) => const OnboardingScreen(),
        PresetsScreen.routeName: (_) => const PresetsScreen(),
      },
    );
  }
}
