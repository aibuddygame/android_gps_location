/// Parses Google Maps share links to extract coordinates
/// 
/// Supports formats:
/// - https://maps.app.goo.gl/ABC123 (short URL - requires expansion)
/// - https://www.google.com/maps/search/?api=1&query=35.6812,139.7671
/// - https://www.google.com/maps/place/.../@35.6812,139.7671,...
/// - https://maps.google.com/?q=35.6812,139.7671
/// - https://goo.gl/maps/ABC123 (legacy short URL)
class MapsLinkParser {
  MapsLinkParser._();

  /// Attempts to parse coordinates from a Google Maps link
  /// Returns null if no coordinates found
  static MapsCoordinates? parse(String url) {
    if (url.isEmpty) return null;
    
    final trimmed = url.trim();
    
    // Try different parsing strategies
    return _parseQueryParam(trimmed) ??
           _parseAtCoordinates(trimmed) ??
           _parseShortUrl(trimmed);
  }

  /// Parse query parameter format: ?q=lat,lng or ?query=lat,lng
  static MapsCoordinates? _parseQueryParam(String url) {
    final queryPatterns = [
      RegExp(r'[?&]q=(-?\d+\.?\d*),(-?\d+\.?\d*)'),
      RegExp(r'[?&]query=(-?\d+\.?\d*),(-?\d+\.?\d*)'),
    ];
    
    for (final pattern in queryPatterns) {
      final match = pattern.firstMatch(url);
      if (match != null) {
        final lat = double.tryParse(match.group(1)!);
        final lng = double.tryParse(match.group(2)!);
        if (lat != null && lng != null && _isValidCoordinate(lat, lng)) {
          return MapsCoordinates(latitude: lat, longitude: lng);
        }
      }
    }
    return null;
  }

  /// Parse @coordinates format: @lat,lng or @lat,lng,zoom
  static MapsCoordinates? _parseAtCoordinates(String url) {
    // Pattern: @35.6812,139.7671 or @35.6812,139.7671,15z
    final pattern = RegExp(r'@(-?\d+\.?\d*),(-?\d+\.?\d*)');
    final match = pattern.firstMatch(url);
    
    if (match != null) {
      final lat = double.tryParse(match.group(1)!);
      final lng = double.tryParse(match.group(2)!);
      if (lat != null && lng != null && _isValidCoordinate(lat, lng)) {
        return MapsCoordinates(latitude: lat, longitude: lng);
      }
    }
    return null;
  }

  /// Parse short URL format (returns placeholder - needs expansion)
  static MapsCoordinates? _parseShortUrl(String url) {
    // Short URLs need to be expanded via HTTP request
    // For now, detect them and return null (UI will show message)
    final shortUrlPatterns = [
      RegExp(r'maps\.app\.goo\.gl'),
      RegExp(r'goo\.gl/maps'),
    ];
    
    for (final pattern in shortUrlPatterns) {
      if (pattern.hasMatch(url)) {
        // Return a marker that this is a short URL
        return MapsCoordinates(
          latitude: 0,
          longitude: 0,
          isShortUrl: true,
          originalUrl: url,
        );
      }
    }
    return null;
  }

  /// Validate coordinates are within valid ranges
  static bool _isValidCoordinate(double lat, double lng) {
    return lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180;
  }

  /// Check if text looks like it might contain coordinates
  static bool mightContainCoordinates(String text) {
    if (text.isEmpty) return false;
    return text.contains('google.com/maps') ||
           text.contains('maps.app.goo.gl') ||
           text.contains('goo.gl/maps') ||
           text.contains('@') && text.contains(',');
  }
}

/// Represents parsed coordinates from a maps link
class MapsCoordinates {
  const MapsCoordinates({
    required this.latitude,
    required this.longitude,
    this.isShortUrl = false,
    this.originalUrl,
  });

  final double latitude;
  final double longitude;
  final bool isShortUrl;
  final String? originalUrl;

  bool get isValid => !isShortUrl && latitude != 0 && longitude != 0;

  @override
  String toString() => 'MapsCoordinates($latitude, $longitude)';
}
