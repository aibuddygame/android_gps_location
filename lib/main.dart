import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'data/repositories/history_repository.dart';
import 'data/repositories/location_repository.dart';
import 'presentation/providers/dashboard_provider.dart';
import 'services/geocoding_service.dart';
import 'services/mock_location_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final repository = LocationRepository();
  await repository.init();
  final historyRepository = HistoryRepository();
  await historyRepository.init();

  runApp(
    MultiProvider(
      providers: [
        Provider<LocationRepository>.value(value: repository),
        Provider<HistoryRepository>.value(value: historyRepository),
        Provider<MockLocationService>(create: (_) => MockLocationService()),
        Provider<GeocodingService>(
          create: (context) => GeocodingService(
            historyRepository: context.read<HistoryRepository>(),
          ),
        ),
        ChangeNotifierProvider<DashboardProvider>(
          create: (context) => DashboardProvider(
            repository: context.read<LocationRepository>(),
            historyRepository: context.read<HistoryRepository>(),
            mockLocationService: context.read<MockLocationService>(),
            geocodingService: context.read<GeocodingService>(),
          )..load(),
        ),
      ],
      child: const GpsLocationChangerApp(),
    ),
  );
}
