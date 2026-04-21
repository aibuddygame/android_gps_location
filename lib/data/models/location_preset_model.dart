import 'dart:convert';

import '../../domain/entities/location_preset.dart';

class LocationPresetModel extends LocationPreset {
  const LocationPresetModel({
    required super.id,
    required super.name,
    required super.latitude,
    required super.longitude,
    super.isBuiltIn,
  });

  factory LocationPresetModel.fromEntity(LocationPreset preset) {
    return LocationPresetModel(
      id: preset.id,
      name: preset.name,
      latitude: preset.latitude,
      longitude: preset.longitude,
      isBuiltIn: preset.isBuiltIn,
    );
  }

  factory LocationPresetModel.fromJson(Map<String, dynamic> json) {
    return LocationPresetModel(
      id: json['id'] as String,
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      isBuiltIn: json['isBuiltIn'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'latitude': latitude,
    'longitude': longitude,
    'isBuiltIn': isBuiltIn,
  };

  String encode() => jsonEncode(toJson());

  static LocationPresetModel decode(String value) {
    return LocationPresetModel.fromJson(
      jsonDecode(value) as Map<String, dynamic>,
    );
  }
}
