import 'package:flutter_test/flutter_test.dart';
import 'package:gps_location_changer/modules/search/place_search_service.dart';

void main() {
  test('missing API key returns actionable error', () async {
    final service = GooglePlacesSearchService(apiKey: '');

    expect(
      () => service.autocomplete('tokyo'),
      throwsA(
        isA<PlaceSearchException>().having(
          (error) => error.message,
          'message',
          contains('GOOGLE_PLACES_API_KEY'),
        ),
      ),
    );
  });
}
