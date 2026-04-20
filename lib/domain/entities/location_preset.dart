class LocationPreset {
  const LocationPreset({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.isBuiltIn = false,
  });

  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final bool isBuiltIn;
}
