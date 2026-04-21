import 'dart:convert';
import 'package:http/http.dart' as http;

/// OpenStreetMap Nominatim API service for location search
/// Free, no API key required
class OpenStreetMapService {
  final http.Client _client;
  
  OpenStreetMapService({http.Client? client}) : _client = client ?? http.Client();
  
  /// Search for locations by query string
  /// Returns list of search results with name, display name, lat, and lon
  Future<List<OSMSearchResult>> search(String query, {int limit = 5}) async {
    if (query.trim().length < 2) return [];
    
    final uri = Uri.https(
      'nominatim.openstreetmap.org',
      '/search',
      {
        'q': query.trim(),
        'format': 'json',
        'limit': limit.toString(),
        'addressdetails': '1',
      },
    );
    
    try {
      final response = await _client.get(
        uri,
        headers: {
          'User-Agent': 'GPSLocationChanger/1.0',
          'Accept': 'application/json',
        },
      );
      
      if (response.statusCode != 200) {
        throw Exception('Search failed: ${response.statusCode}');
      }
      
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => OSMSearchResult.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Search error: $e');
    }
  }
  
  /// Reverse geocode - get location name from coordinates
  Future<OSMSearchResult?> reverseGeocode(double lat, double lon) async {
    final uri = Uri.https(
      'nominatim.openstreetmap.org',
      '/reverse',
      {
        'lat': lat.toString(),
        'lon': lon.toString(),
        'format': 'json',
      },
    );
    
    try {
      final response = await _client.get(
        uri,
        headers: {
          'User-Agent': 'GPSLocationChanger/1.0',
          'Accept': 'application/json',
        },
      );
      
      if (response.statusCode != 200) return null;
      
      final data = json.decode(response.body);
      if (data['error'] != null) return null;
      
      return OSMSearchResult.fromJson(data);
    } catch (e) {
      return null;
    }
  }
  
  void dispose() {
    _client.close();
  }
}

/// OpenStreetMap search result
class OSMSearchResult {
  final String name;
  final String displayName;
  final double lat;
  final double lon;
  final String? type;
  final String? category;
  
  OSMSearchResult({
    required this.name,
    required this.displayName,
    required this.lat,
    required this.lon,
    this.type,
    this.category,
  });
  
  factory OSMSearchResult.fromJson(Map<String, dynamic> json) {
    return OSMSearchResult(
      name: json['name'] ?? '',
      displayName: json['display_name'] ?? '',
      lat: double.tryParse(json['lat']?.toString() ?? '0') ?? 0,
      lon: double.tryParse(json['lon']?.toString() ?? '0') ?? 0,
      type: json['type'],
      category: json['category'],
    );
  }
  
  @override
  String toString() => '$name ($lat, $lon)';
}
