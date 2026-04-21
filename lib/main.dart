import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'data/repositories/history_repository.dart';
import 'data/repositories/location_repository.dart';
import 'modules/ads/ads_service.dart';
import 'modules/mock/mock_location_manager.dart';
import 'modules/privacy/privacy_repository.dart';
import 'modules/search/place_search_service.dart';
import 'modules/settings/app_settings_repository.dart';
import 'presentation/controllers/mvp_controller.dart';
import 'services/geocoding_service.dart';
import 'services/mock_location_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final repository = LocationRepository();
  await repository.init();
  final historyRepository = HistoryRepository();
  await historyRepository.init();
  final privacyRepository = PrivacyRepository();
  await privacyRepository.init();
  final settingsRepository = AppSettingsRepository();
  await settingsRepository.init();

  runApp(
    MultiProvider(
      providers: [
        Provider<LocationRepository>.value(value: repository),
        Provider<HistoryRepository>.value(value: historyRepository),
        Provider<MockLocationService>(create: (_) => MockLocationService()),
        Provider<PrivacyRepository>.value(value: privacyRepository),
        Provider<AppSettingsRepository>.value(value: settingsRepository),
        Provider<AdsService>(create: (_) => const PlaceholderAdsService()),
        Provider<GeocodingService>(
          create: (context) => GeocodingService(
            historyRepository: context.read<HistoryRepository>(),
          ),
        ),
        Provider<PlaceSearchService>(
          create: (_) => GooglePlacesSearchService(),
        ),
        Provider<MockLocationManager>(
          create: (context) => MockLocationManager(
            repository: context.read<LocationRepository>(),
            historyRepository: context.read<HistoryRepository>(),
            mockLocationService: context.read<MockLocationService>(),
            geocodingService: context.read<GeocodingService>(),
          ),
        ),
        ChangeNotifierProvider<MvpController>(
          create: (context) => MvpController(
            mockLocationManager: context.read<MockLocationManager>(),
            privacyRepository: context.read<PrivacyRepository>(),
            settingsRepository: context.read<AppSettingsRepository>(),
            searchService: context.read<PlaceSearchService>(),
            adsService: context.read<AdsService>(),
          )..load(),
        ),
      ],
      child: const GpsLocationChangerApp(),
    ),
  );
}
