import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/formatters.dart';
import '../../data/services/permission_handler.dart';
import '../../domain/entities/mock_location_session.dart';
import '../../modules/ads/ads_service.dart';
import '../../modules/mock/mock_location_manager.dart';
import '../../modules/privacy/models/privacy_preferences.dart';
import '../../modules/privacy/privacy_repository.dart';
import '../../modules/search/models/place_suggestion.dart';
import '../../modules/search/place_search_service.dart';
import '../../modules/settings/app_settings_repository.dart';
import '../../modules/settings/models/app_settings.dart';

class AppLogEntry {
  const AppLogEntry({
    required this.timestamp,
    required this.level,
    required this.message,
  });

  final DateTime timestamp;
  final String level;
  final String message;
}

class MvpController extends ChangeNotifier with WidgetsBindingObserver {
  MvpController({
    required MockLocationManager mockLocationManager,
    required PrivacyRepository privacyRepository,
    required AppSettingsRepository settingsRepository,
    required PlaceSearchService searchService,
    required AdsService adsService,
  })  : _mockLocationManager = mockLocationManager,
        _privacyRepository = privacyRepository,
        _settingsRepository = settingsRepository,
        _searchService = searchService,
        _adsService = adsService;

  final MockLocationManager _mockLocationManager;
  final PrivacyRepository _privacyRepository;
  final AppSettingsRepository _settingsRepository;
  final PlaceSearchService _searchService;
  final AdsService _adsService;

  PrivacyPreferences privacy = PrivacyPreferences.initial();
  AppSettings settings = AppSettings.defaults();
  MockLocationSession session = const MockLocationSession(
    latitude: 35.681236,
    longitude: 139.767125,
    accuracy: AppConstants.defaultAccuracyMeters,
    speed: 0,
    bearing: 0,
    intervalMs: AppConstants.defaultIntervalMs,
  );
  PermissionStatusSnapshot? permissionStatus;
  List<PlaceSuggestion> searchResults = const [];
  List<AppLogEntry> logs = const [];
  String searchQuery = '';
  String? selectedPlaceLabel;
  String? statusMessage;
  String? errorMessage;
  bool isLoading = true;
  bool isSearching = false;
  bool isMutating = false;
  bool advancedExpanded = false;

  Timer? _searchDebounce;
  Timer? _sessionTicker;
  int _searchRun = 0;

  BannerSlotState get bannerSlot => _adsService.buildBannerState(
        consentGranted: privacy.allowBannerAds,
        featureEnabled: settings.showBannerSlot,
      );

  Future<void> load() async {
    WidgetsBinding.instance.addObserver(this);
    privacy = _privacyRepository.load();
    settings = _settingsRepository.load();
    advancedExpanded = !settings.keepAdvancedCollapsed;

    final bootstrap = await _mockLocationManager.bootstrap();
    session = bootstrap.session;
    permissionStatus = bootstrap.permissionStatus;
    selectedPlaceLabel = bootstrap.locationName;
    _restartTicker();
    _pushLog(
      'BOOT',
      'Session draft ${formatCoordinatePair(session.latitude, session.longitude)} loaded.',
    );
    _pushLog(
      permissionStatus?.ready == true ? 'READY' : 'CHECK',
      permissionStatus?.ready == true
          ? 'Device setup ready for mock injection.'
          : 'Review permissions, mock app selection, and location service.',
    );
    isLoading = false;
    notifyListeners();
    unawaited(refreshLocationName());
  }

  bool get requiresConsent => !privacy.hasCompletedConsent;

  Future<void> saveConsent(PrivacyPreferences next) async {
    privacy = next.copyWith(
      hasCompletedConsent: true,
      consentedAt: DateTime.now(),
    );
    await _privacyRepository.save(privacy);
    _pushLog('CONSENT', 'Privacy and safety choices recorded.');
    notifyListeners();
  }

  Future<void> updatePrivacy(PrivacyPreferences next) async {
    privacy = next;
    await _privacyRepository.save(privacy);
    _pushLog('PRIVACY', 'Consent preferences updated.');
    notifyListeners();
  }

  Future<void> updateSettings(AppSettings next) async {
    settings = next;
    advancedExpanded = !next.keepAdvancedCollapsed;
    await _settingsRepository.save(next);
    _pushLog('SETTINGS', 'Application settings updated.');
    notifyListeners();
  }

  Future<void> updateDraft(MockLocationSession next) async {
    session = await _mockLocationManager.saveDraft(next);
    notifyListeners();
  }

  Future<void> searchPlaces(String value) async {
    searchQuery = value;
    errorMessage = null;
    if (!privacy.allowPlacesSearch) {
      searchResults = const [];
      statusMessage = 'Places search disabled by privacy preference.';
      notifyListeners();
      return;
    }

    final trimmed = value.trim();
    _searchDebounce?.cancel();
    if (trimmed.length < 2) {
      searchResults = const [];
      isSearching = false;
      notifyListeners();
      return;
    }

    isSearching = true;
    notifyListeners();
    final searchRun = ++_searchRun;
    _searchDebounce = Timer(const Duration(milliseconds: 320), () async {
      try {
        final results = await _searchService.autocomplete(trimmed);
        if (searchRun != _searchRun) return;
        searchResults = results;
        statusMessage =
            results.isEmpty ? 'No places matched "$trimmed".' : null;
        _pushLog('SEARCH', 'Autocomplete returned ${results.length} row(s).');
      } catch (error) {
        if (searchRun != _searchRun) return;
        errorMessage = error.toString().replaceFirst('Exception: ', '');
        searchResults = const [];
        _pushLog('SEARCH', 'Autocomplete error: $error');
      } finally {
        if (searchRun == _searchRun) {
          isSearching = false;
          notifyListeners();
        }
      }
    });
  }

  Future<void> applySearchResult(PlaceSuggestion suggestion) async {
    selectedPlaceLabel = suggestion.title;
    searchResults = const [];
    searchQuery = suggestion.title;
    statusMessage = 'Selected ${suggestion.title}.';
    await updateDraft(
      session.copyWith(
        latitude: suggestion.latitude,
        longitude: suggestion.longitude,
      ),
    );
    _pushLog(
      'FILL',
      'Draft updated from search result ${suggestion.title}.',
    );
  }

  Future<void> refreshReadiness() async {
    permissionStatus = await _mockLocationManager.refreshPermissions();
    notifyListeners();
  }

  Future<void> requestLocationPermission() async {
    await _mockLocationManager.requestLocationPermission();
    await refreshReadiness();
    _pushLog('PERM', 'Location permission request completed.');
  }

  Future<void> requestLocationService() async {
    await _mockLocationManager.requestLocationService();
    await refreshReadiness();
    _pushLog('SERVICE', 'Location service request completed.');
  }

  Future<void> openDeveloperOptions() async {
    await _mockLocationManager.openDeveloperOptions();
    _pushLog('SETUP', 'Developer options opened.');
  }

  Future<void> startMock({
    required double latitude,
    required double longitude,
    required double accuracy,
    required double speed,
    required double bearing,
    required int intervalMs,
  }) async {
    await refreshReadiness();
    if (permissionStatus?.ready != true) {
      errorMessage = 'Finish setup checks before starting injection.';
      _pushLog('BLOCK', errorMessage!);
      notifyListeners();
      return;
    }

    isMutating = true;
    errorMessage = null;
    statusMessage = null;
    notifyListeners();
    try {
      session = await _mockLocationManager.start(
        session.copyWith(
          latitude: latitude,
          longitude: longitude,
          accuracy: accuracy,
          speed: speed,
          bearing: bearing,
          intervalMs: intervalMs,
        ),
      );
      _restartTicker();
      _pushLog(
        'START',
        'Injecting ${formatCoordinatePair(latitude, longitude)} every ${session.intervalMs} ms.',
      );
      await refreshLocationName();
    } catch (error) {
      errorMessage = error.toString().replaceFirst('Exception: ', '');
      _pushLog('ERROR', errorMessage!);
    } finally {
      isMutating = false;
      notifyListeners();
    }
  }

  Future<void> stopMock() async {
    isMutating = true;
    notifyListeners();
    try {
      session = await _mockLocationManager.stop(session);
      _restartTicker();
      statusMessage = 'Mock session stopped.';
      _pushLog('STOP', 'Background mock service stopped.');
    } catch (error) {
      errorMessage = error.toString().replaceFirst('Exception: ', '');
      _pushLog('ERROR', errorMessage!);
    } finally {
      isMutating = false;
      notifyListeners();
    }
  }

  Future<void> refreshLocationName() async {
    try {
      final name = await _mockLocationManager.resolveLocationName(session);
      if (name != null && name.trim().isNotEmpty) {
        selectedPlaceLabel = name;
        notifyListeners();
      }
    } catch (_) {}
  }

  void clearMessages() {
    statusMessage = null;
    errorMessage = null;
    notifyListeners();
  }

  void setAdvancedExpanded(bool expanded) {
    advancedExpanded = expanded;
    notifyListeners();
  }

  void _restartTicker() {
    _sessionTicker?.cancel();
    if (!session.isActive) return;
    _sessionTicker = Timer.periodic(
      Duration(milliseconds: session.intervalMs),
      (_) {
        session = session.copyWith(lastUpdateAt: DateTime.now());
        notifyListeners();
      },
    );
  }

  void _pushLog(String level, String message) {
    final next = [
      AppLogEntry(timestamp: DateTime.now(), level: level, message: message),
      ...logs,
    ];
    logs = next.take(settings.showVerboseLogs ? 40 : 12).toList();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(refreshReadiness());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchDebounce?.cancel();
    _sessionTicker?.cancel();
    _searchService.dispose();
    super.dispose();
  }
}
