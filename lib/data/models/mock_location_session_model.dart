import 'dart:convert';

import '../../domain/entities/mock_location_session.dart';

class MockLocationSessionModel extends MockLocationSession {
  const MockLocationSessionModel({
    required super.latitude,
    required super.longitude,
    required super.accuracy,
    required super.speed,
    required super.bearing,
    required super.intervalMs,
    super.startedAt,
    super.lastUpdateAt,
    super.isActive,
    super.isBackgroundCapable,
  });

  factory MockLocationSessionModel.fromEntity(MockLocationSession session) {
    return MockLocationSessionModel(
      latitude: session.latitude,
      longitude: session.longitude,
      accuracy: session.accuracy,
      speed: session.speed,
      bearing: session.bearing,
      intervalMs: session.intervalMs,
      startedAt: session.startedAt,
      lastUpdateAt: session.lastUpdateAt,
      isActive: session.isActive,
      isBackgroundCapable: session.isBackgroundCapable,
    );
  }

  factory MockLocationSessionModel.fromJson(Map<String, dynamic> json) {
    return MockLocationSessionModel(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      accuracy: (json['accuracy'] as num).toDouble(),
      speed: (json['speed'] as num).toDouble(),
      bearing: (json['bearing'] as num).toDouble(),
      intervalMs: json['intervalMs'] as int,
      startedAt: json['startedAt'] == null
          ? null
          : DateTime.parse(json['startedAt'] as String),
      lastUpdateAt: json['lastUpdateAt'] == null
          ? null
          : DateTime.parse(json['lastUpdateAt'] as String),
      isActive: json['isActive'] as bool? ?? false,
      isBackgroundCapable: json['isBackgroundCapable'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    'accuracy': accuracy,
    'speed': speed,
    'bearing': bearing,
    'intervalMs': intervalMs,
    'startedAt': startedAt?.toIso8601String(),
    'lastUpdateAt': lastUpdateAt?.toIso8601String(),
    'isActive': isActive,
    'isBackgroundCapable': isBackgroundCapable,
  };

  String encode() => jsonEncode(toJson());

  static MockLocationSessionModel decode(String value) {
    return MockLocationSessionModel.fromJson(
      jsonDecode(value) as Map<String, dynamic>,
    );
  }
}
