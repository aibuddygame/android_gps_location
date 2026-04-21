class BannerSlotState {
  const BannerSlotState({
    required this.visible,
    required this.label,
    required this.message,
  });

  final bool visible;
  final String label;
  final String message;
}

abstract class AdsService {
  const AdsService();

  String get providerName;

  BannerSlotState buildBannerState({
    required bool consentGranted,
    required bool featureEnabled,
  });
}

class PlaceholderAdsService extends AdsService {
  const PlaceholderAdsService();

  @override
  String get providerName => 'Banner Slot Placeholder';

  @override
  BannerSlotState buildBannerState({
    required bool consentGranted,
    required bool featureEnabled,
  }) {
    if (!featureEnabled || !consentGranted) {
      return const BannerSlotState(
        visible: false,
        label: 'ADS OFF',
        message: 'Banner placement disabled in settings or consent.',
      );
    }
    return const BannerSlotState(
      visible: true,
      label: 'PHASE 1 SLOT',
      message: 'Lightweight banner abstraction ready for AdMob or mediation.',
    );
  }
}
