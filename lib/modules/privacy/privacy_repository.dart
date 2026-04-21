import 'package:shared_preferences/shared_preferences.dart';

import 'models/privacy_preferences.dart';

class PrivacyRepository {
  static const _preferencesKey = 'privacy_preferences_v1';

  late final SharedPreferences _preferences;

  Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  PrivacyPreferences load() {
    final value = _preferences.getString(_preferencesKey);
    if (value == null) return PrivacyPreferences.initial();
    return PrivacyPreferences.decode(value);
  }

  Future<void> save(PrivacyPreferences value) async {
    await _preferences.setString(_preferencesKey, value.encode());
  }
}
