import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../../domain/entities/location_preset.dart';
import '../../domain/entities/mock_location_session.dart';
import '../models/location_preset_model.dart';
import '../models/mock_location_session_model.dart';

class LocationRepository {
  static const _presetsKey = 'presets';
  static const _lastSessionKey = 'lastSession';
  static const _seenOnboardingKey = 'seenOnboarding';
  static const _acceptedConsentKey = 'acceptedConsent';
  static const _allowSearchKey = 'allowSearch';

  late final SharedPreferences _preferences;

  Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  List<LocationPreset> loadPresets() {
    final saved = _preferences.getStringList(_presetsKey) ?? const [];
    final custom = saved
        .map(LocationPresetModel.decode)
        .where((preset) => !preset.isBuiltIn)
        .toList();
    return [...builtInPresets, ...custom];
  }

  Future<void> savePreset(LocationPreset preset) async {
    final custom = loadPresets().where((item) => !item.isBuiltIn).toList();
    final index = custom.indexWhere((item) => item.id == preset.id);
    final model = LocationPresetModel.fromEntity(preset);
    if (index >= 0) {
      custom[index] = model;
    } else {
      custom.add(model);
    }
    await _preferences.setStringList(
      _presetsKey,
      custom
          .map((item) => LocationPresetModel.fromEntity(item).encode())
          .toList(),
    );
  }

  Future<void> deletePreset(String id) async {
    final custom = loadPresets()
        .where((item) => !item.isBuiltIn && item.id != id)
        .map((item) => LocationPresetModel.fromEntity(item).encode())
        .toList();
    await _preferences.setStringList(_presetsKey, custom);
  }

  MockLocationSession loadLastSession() {
    final value = _preferences.getString(_lastSessionKey);
    if (value == null) {
      return const MockLocationSession(
        latitude: 35.681236,
        longitude: 139.767125,
        accuracy: AppConstants.defaultAccuracyMeters,
        speed: 0,
        bearing: 0,
        intervalMs: AppConstants.defaultIntervalMs,
      );
    }
    return MockLocationSessionModel.decode(value);
  }

  Future<void> saveLastSession(MockLocationSession session) async {
    await _preferences.setString(
      _lastSessionKey,
      MockLocationSessionModel.fromEntity(session).encode(),
    );
  }

  bool hasSeenOnboarding() {
    return _preferences.getBool(_seenOnboardingKey) ?? false;
  }

  Future<void> setSeenOnboarding() async {
    await _preferences.setBool(_seenOnboardingKey, true);
  }

  static const builtInPresets = <LocationPreset>[];

  bool hasAcceptedConsent() {
    return _preferences.getBool(_acceptedConsentKey) ?? false;
  }

  bool allowPlacesSearch() {
    return _preferences.getBool(_allowSearchKey) ?? true;
  }

  Future<void> saveConsent({
    required bool acceptedSafety,
    required bool allowSearch,
  }) async {
    await _preferences.setBool(_acceptedConsentKey, acceptedSafety);
    await _preferences.setBool(_allowSearchKey, allowSearch);
  }
}
