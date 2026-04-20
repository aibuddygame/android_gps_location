import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../core/constants/app_constants.dart';
import '../../data/models/location_history_model.dart';
import '../../data/repositories/history_repository.dart';
import '../../data/repositories/location_repository.dart';
import '../../data/services/permission_handler.dart';
import '../../domain/entities/location_preset.dart';
import '../../domain/entities/mock_location_session.dart';
import '../../domain/usecases/build_mock_location_session.dart';
import '../../services/geocoding_service.dart';
import '../../services/mock_location_service.dart';

class DashboardProvider extends ChangeNotifier {
  DashboardProvider({
    required LocationRepository repository,
    required HistoryRepository historyRepository,
    required MockLocationService mockLocationService,
    required GeocodingService geocodingService,
  })  : _repository = repository,
        _historyRepository = historyRepository,
        _mockLocationService = mockLocationService,
        _geocodingService = geocodingService,
        _permissionHandler = PermissionHandler(mockLocationService);

  final LocationRepository _repository;
  final HistoryRepository _historyRepository;
  final MockLocationService _mockLocationService;
  final GeocodingService _geocodingService;
  final PermissionHandler _permissionHandler;
  final BuildMockLocationSession _buildSession =
      const BuildMockLocationSession();

  List<LocationPreset> presets = const [];
  List<LocationHistoryModel> history = const [];
  MockLocationSession? session;
  PermissionStatusSnapshot? permissionStatus;
  bool isBusy = false;
  bool isResolvingLocationName = false;
  String? errorMessage;
  String? infoMessage;
  String? currentLocationName;
  Timer? _debugTimer;

  bool get hasSeenOnboarding => _repository.hasSeenOnboarding();

  Future<void> load() async {
    presets = _repository.loadPresets();
    history = await _historyRepository.loadHistory();
    final saved = _repository.loadLastSession();
    final nativeRunning = await _mockLocationService.isRunning();
    session = saved.copyWith(isActive: nativeRunning);
    await _loadCachedLocationName(session!);
    permissionStatus = await _permissionHandler.check();
    _startDebugClockIfNeeded();
    notifyListeners();
    unawaited(resolveCurrentLocationName());
  }

  Future<void> refreshChecks() async {
    permissionStatus = await _permissionHandler.check();
    notifyListeners();
  }

  Future<void> requestPermission() async {
    await _permissionHandler.requestLocationPermission();
    await refreshChecks();
  }

  Future<void> requestLocationService() async {
    await _permissionHandler.requestLocationService();
    await refreshChecks();
  }

  Future<void> openDeveloperOptions() async {
    await _permissionHandler.openDeveloperOptions();
  }

  Future<void> completeOnboarding() async {
    await _repository.setSeenOnboarding();
    notifyListeners();
  }

  Future<void> start({
    required double latitude,
    required double longitude,
    required double accuracy,
    required double speed,
    required double bearing,
    required int intervalMs,
  }) async {
    await _runBusy(() async {
      errorMessage = null;
      permissionStatus = await _permissionHandler.check();
      if (permissionStatus?.ready != true) {
        errorMessage = 'Complete setup before starting mock location.';
        return;
      }

      final next = _buildSession(
        latitude: latitude,
        longitude: longitude,
        accuracy: accuracy,
        speed: speed,
        bearing: bearing,
        intervalMs: intervalMs.clamp(
          AppConstants.minIntervalMs,
          AppConstants.maxIntervalMs,
        ),
      );
      await _mockLocationService.start(next);
      session = next.copyWith(lastUpdateAt: DateTime.now());
      await _repository.saveLastSession(session!);
      await _loadCachedLocationName(session!);
      await _recordHistory(session!);
      infoMessage = 'Mock location active';
      _startDebugClockIfNeeded();
      unawaited(resolveCurrentLocationName());
    });
  }

  Future<void> stop() async {
    await _runBusy(() async {
      await _mockLocationService.stop();
      session = (session ?? _repository.loadLastSession()).copyWith(
        isActive: false,
        lastUpdateAt: DateTime.now(),
      );
      await _repository.saveLastSession(session!);
      infoMessage = 'Mock location stopped';
      _debugTimer?.cancel();
    });
  }

  Future<void> savePreset({
    required String name,
    required double latitude,
    required double longitude,
  }) async {
    final preset = LocationPreset(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name.trim(),
      latitude: latitude,
      longitude: longitude,
    );
    await _repository.savePreset(preset);
    presets = _repository.loadPresets();
    notifyListeners();
  }

  Future<void> deletePreset(String id) async {
    await _repository.deletePreset(id);
    presets = _repository.loadPresets();
    notifyListeners();
  }

  Future<void> persistDraft(MockLocationSession draft) async {
    session = draft;
    await _repository.saveLastSession(draft);
    await _loadCachedLocationName(draft);
    notifyListeners();
    unawaited(resolveCurrentLocationName());
  }

  Future<void> refreshHistory() async {
    history = await _historyRepository.loadHistory();
    notifyListeners();
  }

  Future<void> clearHistory() async {
    await _historyRepository.clearHistory();
    history = const [];
    notifyListeners();
  }

  Future<void> updateHistoryLocationName(
    LocationHistoryModel item,
    String? locationName,
  ) async {
    await _historyRepository.updateLocationName(item, locationName);
    final trimmed = locationName?.trim();
    final savedName = trimmed == null || trimmed.isEmpty ? null : trimmed;
    history = history
        .map(
          (historyItem) => historyItem.coordinateKey == item.coordinateKey
              ? historyItem.copyWith(locationName: savedName)
              : historyItem,
        )
        .toList();

    final current = session;
    if (current != null &&
        LocationHistoryModel.coordinateKeyFor(
              current.latitude,
              current.longitude,
            ) ==
            item.coordinateKey) {
      currentLocationName = savedName;
    }
    notifyListeners();
  }

  Future<void> useHistoryLocation(LocationHistoryModel item) async {
    final draft = item.toSession(session ?? _repository.loadLastSession());
    session = draft;
    currentLocationName = item.locationName;
    await _repository.saveLastSession(draft);
    notifyListeners();
  }

  Future<void> resolveCurrentLocationName() async {
    final current = session;
    if (current == null || isResolvingLocationName) return;

    isResolvingLocationName = true;
    notifyListeners();
    try {
      final name = await _geocodingService.reverseGeocode(
        current.latitude,
        current.longitude,
      );
      if (name == null || session == null) return;
      if (session!.latitude != current.latitude ||
          session!.longitude != current.longitude) {
        return;
      }
      currentLocationName = name;
      history = await _historyRepository.loadHistory();
    } finally {
      isResolvingLocationName = false;
      notifyListeners();
    }
  }

  void clearMessages() {
    errorMessage = null;
    infoMessage = null;
  }

  Future<void> _runBusy(Future<void> Function() action) async {
    isBusy = true;
    notifyListeners();
    try {
      await action();
    } catch (error) {
      errorMessage = error.toString().replaceFirst('Exception: ', '');
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }

  void _startDebugClockIfNeeded() {
    _debugTimer?.cancel();
    if (session?.isActive != true) return;
    _debugTimer = Timer.periodic(Duration(milliseconds: session!.intervalMs), (
      _,
    ) {
      session = session?.copyWith(lastUpdateAt: DateTime.now());
      notifyListeners();
    });
  }

  Future<void> _recordHistory(MockLocationSession current) async {
    final item = await _historyRepository.recordLocation(
      current,
      locationName: currentLocationName,
    );
    currentLocationName = item.locationName ?? currentLocationName;
    history = await _historyRepository.loadHistory();
  }

  Future<void> _loadCachedLocationName(MockLocationSession current) async {
    currentLocationName = await _historyRepository.getCachedLocationName(
      current.latitude,
      current.longitude,
    );
  }

  @override
  void dispose() {
    _debugTimer?.cancel();
    _geocodingService.dispose();
    super.dispose();
  }
}
