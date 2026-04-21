import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/constants/app_constants.dart';
import 'models/place_suggestion.dart';

class PlaceSearchException implements Exception {
  const PlaceSearchException(this.message);

  final String message;

  @override
  String toString() => message;
}

abstract class PlaceSearchService {
  Future<List<PlaceSuggestion>> autocomplete(String query);

  void dispose();
}

class GooglePlacesSearchService implements PlaceSearchService {
  GooglePlacesSearchService({
    http.Client? client,
    String apiKey = const String.fromEnvironment('GOOGLE_PLACES_API_KEY'),
  })  : _client = client ?? http.Client(),
        _apiKey = apiKey;

  final http.Client _client;
  final String _apiKey;

  @override
  Future<List<PlaceSuggestion>> autocomplete(String query) async {
    final trimmed = query.trim();
    if (trimmed.length < 2) return const [];
    if (_apiKey.isEmpty) {
      throw const PlaceSearchException(
        'Missing GOOGLE_PLACES_API_KEY dart define.',
      );
    }

    final predictionsUri = Uri.https(
      'maps.googleapis.com',
      '/maps/api/place/autocomplete/json',
      {
        'input': trimmed,
        'types': 'geocode',
        'key': _apiKey,
      },
    );
    final predictionsResponse = await _client.get(predictionsUri);
    if (predictionsResponse.statusCode != 200) {
      throw PlaceSearchException(
        'Places autocomplete failed with ${predictionsResponse.statusCode}.',
      );
    }

    final payload =
        jsonDecode(predictionsResponse.body) as Map<String, dynamic>;
    final status = payload['status'] as String? ?? 'UNKNOWN_ERROR';
    if (status == 'ZERO_RESULTS') return const [];
    if (status != 'OK') {
      throw PlaceSearchException('Places autocomplete returned $status.');
    }

    final predictions = (payload['predictions'] as List<dynamic>? ?? const [])
        .take(AppConstants.maxSearchResults)
        .cast<Map<String, dynamic>>()
        .toList();

    final suggestions = await Future.wait(
      predictions.map(_resolvePrediction),
    );
    return suggestions.whereType<PlaceSuggestion>().toList();
  }

  Future<PlaceSuggestion?> _resolvePrediction(
    Map<String, dynamic> prediction,
  ) async {
    final placeId = prediction['place_id'] as String?;
    if (placeId == null || placeId.isEmpty) return null;

    final detailsUri = Uri.https(
      'maps.googleapis.com',
      '/maps/api/place/details/json',
      {
        'place_id': placeId,
        'fields': 'geometry/location,name,formatted_address',
        'key': _apiKey,
      },
    );
    final detailsResponse = await _client.get(detailsUri);
    if (detailsResponse.statusCode != 200) return null;

    final payload = jsonDecode(detailsResponse.body) as Map<String, dynamic>;
    if ((payload['status'] as String?) != 'OK') return null;

    final result = payload['result'] as Map<String, dynamic>? ?? const {};
    final geometry = result['geometry'] as Map<String, dynamic>? ?? const {};
    final location = geometry['location'] as Map<String, dynamic>? ?? const {};
    final latitude = (location['lat'] as num?)?.toDouble();
    final longitude = (location['lng'] as num?)?.toDouble();
    if (latitude == null || longitude == null) return null;

    return PlaceSuggestion(
      placeId: placeId,
      title: result['name'] as String? ?? 'Unknown place',
      subtitle: result['formatted_address'] as String? ?? '',
      latitude: latitude,
      longitude: longitude,
    );
  }

  @override
  void dispose() {
    _client.close();
  }
}
