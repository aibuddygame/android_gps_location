class MockLocationSession {
  const MockLocationSession({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.speed,
    required this.bearing,
    required this.intervalMs,
    this.startedAt,
    this.lastUpdateAt,
    this.isActive = false,
    this.isBackgroundCapable = false,
  });

  final double latitude;
  final double longitude;
  final double accuracy;
  final double speed;
  final double bearing;
  final int intervalMs;
  final DateTime? startedAt;
  final DateTime? lastUpdateAt;
  final bool isActive;
  final bool isBackgroundCapable;

  MockLocationSession copyWith({
    double? latitude,
    double? longitude,
    double? accuracy,
    double? speed,
    double? bearing,
    int? intervalMs,
    DateTime? startedAt,
    DateTime? lastUpdateAt,
    bool? isActive,
    bool? isBackgroundCapable,
  }) {
    return MockLocationSession(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      accuracy: accuracy ?? this.accuracy,
      speed: speed ?? this.speed,
      bearing: bearing ?? this.bearing,
      intervalMs: intervalMs ?? this.intervalMs,
      startedAt: startedAt ?? this.startedAt,
      lastUpdateAt: lastUpdateAt ?? this.lastUpdateAt,
      isActive: isActive ?? this.isActive,
      isBackgroundCapable: isBackgroundCapable ?? this.isBackgroundCapable,
    );
  }
}
