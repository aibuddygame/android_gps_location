import 'dart:convert';

class PrivacyPreferences {
  const PrivacyPreferences({
    required this.hasCompletedConsent,
    required this.acceptedSafetyNotice,
    required this.allowPlacesSearch,
    required this.allowBannerAds,
    this.consentedAt,
  });

  final bool hasCompletedConsent;
  final bool acceptedSafetyNotice;
  final bool allowPlacesSearch;
  final bool allowBannerAds;
  final DateTime? consentedAt;

  factory PrivacyPreferences.initial() {
    return const PrivacyPreferences(
      hasCompletedConsent: false,
      acceptedSafetyNotice: false,
      allowPlacesSearch: true,
      allowBannerAds: true,
    );
  }

  PrivacyPreferences copyWith({
    bool? hasCompletedConsent,
    bool? acceptedSafetyNotice,
    bool? allowPlacesSearch,
    bool? allowBannerAds,
    DateTime? consentedAt,
  }) {
    return PrivacyPreferences(
      hasCompletedConsent: hasCompletedConsent ?? this.hasCompletedConsent,
      acceptedSafetyNotice: acceptedSafetyNotice ?? this.acceptedSafetyNotice,
      allowPlacesSearch: allowPlacesSearch ?? this.allowPlacesSearch,
      allowBannerAds: allowBannerAds ?? this.allowBannerAds,
      consentedAt: consentedAt ?? this.consentedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'hasCompletedConsent': hasCompletedConsent,
        'acceptedSafetyNotice': acceptedSafetyNotice,
        'allowPlacesSearch': allowPlacesSearch,
        'allowBannerAds': allowBannerAds,
        'consentedAt': consentedAt?.toIso8601String(),
      };

  factory PrivacyPreferences.fromJson(Map<String, dynamic> json) {
    return PrivacyPreferences(
      hasCompletedConsent: json['hasCompletedConsent'] as bool? ?? false,
      acceptedSafetyNotice: json['acceptedSafetyNotice'] as bool? ?? false,
      allowPlacesSearch: json['allowPlacesSearch'] as bool? ?? true,
      allowBannerAds: json['allowBannerAds'] as bool? ?? true,
      consentedAt: json['consentedAt'] == null
          ? null
          : DateTime.parse(json['consentedAt'] as String),
    );
  }

  String encode() => jsonEncode(toJson());

  static PrivacyPreferences decode(String value) {
    return PrivacyPreferences.fromJson(
      jsonDecode(value) as Map<String, dynamic>,
    );
  }
}
