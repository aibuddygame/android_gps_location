import 'package:flutter/services.dart';

import '../domain/entities/mock_location_session.dart';

class MockLocationService {
  static const _channel = MethodChannel('gps_location_changer/mock_location');

  Future<void> start(MockLocationSession session) async {
    await _channel.invokeMethod<void>('start', {
      'latitude': session.latitude,
      'longitude': session.longitude,
      'accuracy': session.accuracy,
      'speed': session.speed,
      'bearing': session.bearing,
      'intervalMs': session.intervalMs,
    });
  }

  Future<void> stop() async {
    await _channel.invokeMethod<void>('stop');
  }

  Future<bool> isRunning() async {
    return await _channel.invokeMethod<bool>('isRunning') ?? false;
  }

  Future<bool> isMockLocationEnabled() async {
    return await _channel.invokeMethod<bool>('isMockLocationEnabled') ?? false;
  }

  Future<void> openDeveloperOptions() async {
    await _channel.invokeMethod<void>('openDeveloperOptions');
  }
}
