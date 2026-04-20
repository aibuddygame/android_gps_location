import '../../domain/entities/mock_location_session.dart';

class LocationHistoryModel {
  const LocationHistoryModel({
    this.id,
    required this.coordinateKey,
    required this.latitude,
    required this.longitude,
    required this.firstUsedAt,
    required this.lastUsedAt,
    required this.useCount,
    this.locationName,
  });

  final int? id;
  final String coordinateKey;
  final double latitude;
  final double longitude;
  final DateTime firstUsedAt;
  final DateTime lastUsedAt;
  final int useCount;
  final String? locationName;

  static const Object _unchanged = Object();

  LocationHistoryModel copyWith({
    int? id,
    String? coordinateKey,
    double? latitude,
    double? longitude,
    DateTime? firstUsedAt,
    DateTime? lastUsedAt,
    int? useCount,
    Object? locationName = _unchanged,
  }) {
    return LocationHistoryModel(
      id: id ?? this.id,
      coordinateKey: coordinateKey ?? this.coordinateKey,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      firstUsedAt: firstUsedAt ?? this.firstUsedAt,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      useCount: useCount ?? this.useCount,
      locationName: identical(locationName, _unchanged)
          ? this.locationName
          : locationName as String?,
    );
  }

  factory LocationHistoryModel.fromRow(Map<String, Object?> row) {
    return LocationHistoryModel(
      id: row['id'] as int?,
      coordinateKey: row['coordinate_key'] as String,
      latitude: (row['latitude'] as num).toDouble(),
      longitude: (row['longitude'] as num).toDouble(),
      firstUsedAt: DateTime.fromMillisecondsSinceEpoch(
        row['first_used_at'] as int,
      ),
      lastUsedAt: DateTime.fromMillisecondsSinceEpoch(
        row['last_used_at'] as int,
      ),
      useCount: row['use_count'] as int,
      locationName: row['location_name'] as String?,
    );
  }

  MockLocationSession toSession(MockLocationSession defaults) {
    return defaults.copyWith(
      latitude: latitude,
      longitude: longitude,
      isActive: false,
    );
  }

  String get coordinates {
    return '${latitude.toStringAsFixed(7)}, ${longitude.toStringAsFixed(7)}';
  }

  static String coordinateKeyFor(double latitude, double longitude) {
    return '${latitude.toStringAsFixed(6)},${longitude.toStringAsFixed(6)}';
  }
}
