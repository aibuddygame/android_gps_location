import '../../core/constants/app_constants.dart';
import '../entities/mock_location_session.dart';

class BuildMockLocationSession {
  const BuildMockLocationSession();

  MockLocationSession call({
    required double latitude,
    required double longitude,
    double? accuracy,
    double? speed,
    double? bearing,
    int? intervalMs,
  }) {
    return MockLocationSession(
      latitude: latitude,
      longitude: longitude,
      accuracy: accuracy ?? AppConstants.defaultAccuracyMeters,
      speed: speed ?? 0,
      bearing: bearing ?? 0,
      intervalMs: intervalMs ?? AppConstants.defaultIntervalMs,
      startedAt: DateTime.now(),
      isActive: true,
      isBackgroundCapable: true,
    );
  }
}
