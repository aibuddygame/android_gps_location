import 'dart:convert';

class AppSettings {
  const AppSettings({
    required this.showVerboseLogs,
    required this.showBannerSlot,
    required this.keepAdvancedCollapsed,
  });

  final bool showVerboseLogs;
  final bool showBannerSlot;
  final bool keepAdvancedCollapsed;

  factory AppSettings.defaults() {
    return const AppSettings(
      showVerboseLogs: true,
      showBannerSlot: true,
      keepAdvancedCollapsed: true,
    );
  }

  AppSettings copyWith({
    bool? showVerboseLogs,
    bool? showBannerSlot,
    bool? keepAdvancedCollapsed,
  }) {
    return AppSettings(
      showVerboseLogs: showVerboseLogs ?? this.showVerboseLogs,
      showBannerSlot: showBannerSlot ?? this.showBannerSlot,
      keepAdvancedCollapsed:
          keepAdvancedCollapsed ?? this.keepAdvancedCollapsed,
    );
  }

  Map<String, dynamic> toJson() => {
        'showVerboseLogs': showVerboseLogs,
        'showBannerSlot': showBannerSlot,
        'keepAdvancedCollapsed': keepAdvancedCollapsed,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      showVerboseLogs: json['showVerboseLogs'] as bool? ?? true,
      showBannerSlot: json['showBannerSlot'] as bool? ?? true,
      keepAdvancedCollapsed: json['keepAdvancedCollapsed'] as bool? ?? true,
    );
  }

  String encode() => jsonEncode(toJson());

  static AppSettings decode(String value) {
    return AppSettings.fromJson(jsonDecode(value) as Map<String, dynamic>);
  }
}
