import '../../data/repositories/history_repository.dart';
import '../../data/repositories/location_repository.dart';
import '../../data/services/permission_handler.dart';
import '../../domain/entities/mock_location_session.dart';
import '../../services/geocoding_service.dart';
import '../../services/mock_location_service.dart';

class MockLocationBootstrap {
  const MockLocationBootstrap({
    required this.session,
    required this.permissionStatus,
    required this.locationName,
  });

  final MockLocationSession session;
  final PermissionStatusSnapshot permissionStatus;
  final String? locationName;
}

class MockLocationManager {
  MockLocationManager({
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

  Future<MockLocationBootstrap> bootstrap() async {
    final stored = _repository.loadLastSession();
    final running = await _mockLocationService.isRunning();
    final session = stored.copyWith(
      isActive: running,
      isBackgroundCapable: true,
    );
    final permissionStatus = await _permissionHandler.check();
    final locationName = await _historyRepository.getCachedLocationName(
      session.latitude,
      session.longitude,
    );
    return MockLocationBootstrap(
      session: session,
      permissionStatus: permissionStatus,
      locationName: locationName,
    );
  }

  Future<PermissionStatusSnapshot> refreshPermissions() {
    return _permissionHandler.check();
  }

  Future<void> requestLocationPermission() async {
    await _permissionHandler.requestLocationPermission();
  }

  Future<void> requestLocationService() async {
    await _permissionHandler.requestLocationService();
  }

  Future<void> openDeveloperOptions() {
    return _permissionHandler.openDeveloperOptions();
  }

  Future<MockLocationSession> saveDraft(MockLocationSession draft) async {
    await _repository.saveLastSession(draft);
    return draft;
  }

  Future<MockLocationSession> start(MockLocationSession draft) async {
    await _mockLocationService.start(draft);
    final next = draft.copyWith(
      isActive: true,
      isBackgroundCapable: true,
      startedAt: DateTime.now(),
      lastUpdateAt: DateTime.now(),
    );
    await _repository.saveLastSession(next);
    await _historyRepository.recordLocation(next);
    return next;
  }

  Future<MockLocationSession> stop(MockLocationSession session) async {
    await _mockLocationService.stop();
    final next = session.copyWith(isActive: false);
    await _repository.saveLastSession(next);
    return next;
  }

  Future<String?> resolveLocationName(MockLocationSession session) {
    return _geocodingService.reverseGeocode(
        session.latitude, session.longitude);
  }
}
