import 'package:shared_preferences/shared_preferences.dart';

import 'models/app_settings.dart';

class AppSettingsRepository {
  static const _settingsKey = 'app_settings_v1';

  late final SharedPreferences _preferences;

  Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  AppSettings load() {
    final value = _preferences.getString(_settingsKey);
    if (value == null) return AppSettings.defaults();
    return AppSettings.decode(value);
  }

  Future<void> save(AppSettings settings) async {
    await _preferences.setString(_settingsKey, settings.encode());
  }
}
