import 'dart:convert';
import 'package:http/http.dart' as http;

/// OpenStreetMap Nominatim API service for location search
/// Free, no API key required
class OpenStreetMapService {
  final http.Client _client;
  
  OpenStreetMapService({http.Client? client}) : _client = client ?? http.Client();
  
  /// Search for locations by query string
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
  
  OSMSearchResult({
    required this.name,
    required this.displayName,
    required this.lat,
    required this.lon,
  });
  
  factory OSMSearchResult.fromJson(Map<String, dynamic> json) {
    return OSMSearchResult(
      name: json['name'] ?? '',
      displayName: json['display_name'] ?? '',
      lat: double.tryParse(json['lat']?.toString() ?? '0') ?? 0,
      lon: double.tryParse(json['lon']?.toString() ?? '0') ?? 0,
    );
  }
}
