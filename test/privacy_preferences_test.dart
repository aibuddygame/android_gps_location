import 'package:flutter_test/flutter_test.dart';
import 'package:gps_location_changer/modules/privacy/models/privacy_preferences.dart';

void main() {
  test('privacy preferences round-trip encode/decode', () {
    final model = PrivacyPreferences(
      hasCompletedConsent: true,
      acceptedSafetyNotice: true,
      allowPlacesSearch: false,
      allowBannerAds: true,
      consentedAt: DateTime.parse('2026-04-21T08:15:00Z'),
    );

    final decoded = PrivacyPreferences.decode(model.encode());

    expect(decoded.hasCompletedConsent, isTrue);
    expect(decoded.acceptedSafetyNotice, isTrue);
    expect(decoded.allowPlacesSearch, isFalse);
    expect(decoded.allowBannerAds, isTrue);
    expect(decoded.consentedAt, DateTime.parse('2026-04-21T08:15:00Z'));
  });
}
