import 'dart:convert';

import 'package:http/http.dart' as http;

import '../data/repositories/history_repository.dart';

class GeocodingService {
  GeocodingService({
    required HistoryRepository historyRepository,
    http.Client? client,
    String apiKey = const String.fromEnvironment('GOOGLE_MAPS_API_KEY'),
  })  : _historyRepository = historyRepository,
        _client = client ?? http.Client(),
        _apiKey = apiKey;

  final HistoryRepository _historyRepository;
  final http.Client _client;
  final String _apiKey;

  Future<String?> reverseGeocode(double latitude, double longitude) async {
    final cached = await _historyRepository.getCachedLocationName(
      latitude,
      longitude,
    );
    if (cached != null && cached.trim().isNotEmpty) return cached;
    if (_apiKey.trim().isEmpty) return null;

    final uri = Uri.https('maps.googleapis.com', '/maps/api/geocode/json', {
      'latlng': '$latitude,$longitude',
      'key': _apiKey,
    });

    final response = await _client.get(uri);
    if (response.statusCode != 200) return null;

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    if (payload['status'] != 'OK') return null;

    final results = payload['results'] as List<dynamic>? ?? const [];
    if (results.isEmpty) return null;

    final first = results.first as Map<String, dynamic>;
    final formattedAddress = first['formatted_address'] as String?;
    if (formattedAddress == null || formattedAddress.trim().isEmpty) {
      return null;
    }

    await _historyRepository.cacheLocationName(
      latitude: latitude,
      longitude: longitude,
      locationName: formattedAddress,
    );
    return formattedAddress;
  }

  void dispose() {
    _client.close();
  }
}
