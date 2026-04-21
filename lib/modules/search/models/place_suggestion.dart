class PlaceSuggestion {
  const PlaceSuggestion({
    required this.placeId,
    required this.title,
    required this.subtitle,
    required this.latitude,
    required this.longitude,
  });

  final String placeId;
  final String title;
  final String subtitle;
  final double latitude;
  final double longitude;
}
