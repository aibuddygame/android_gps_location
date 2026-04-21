import 'package:geolocator/geolocator.dart' as geo;
import 'package:location/location.dart' as loc;

import '../../services/mock_location_service.dart';

class PermissionHandler {
  PermissionHandler(this._mockLocationService);

  final MockLocationService _mockLocationService;
  final loc.Location _location = loc.Location();

  Future<PermissionStatusSnapshot> check() async {
    final serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
    final permission = await geo.Geolocator.checkPermission();
    final mockLocationEnabled = await _mockLocationService
        .isMockLocationEnabled();
    return PermissionStatusSnapshot(
      locationServiceEnabled: serviceEnabled,
      locationPermission: permission,
      mockLocationEnabled: mockLocationEnabled,
    );
  }

  Future<geo.LocationPermission> requestLocationPermission() async {
    return geo.Geolocator.requestPermission();
  }

  Future<bool> requestLocationService() async {
    return _location.requestService();
  }

  Future<void> openLocationSettings() {
    return geo.Geolocator.openLocationSettings();
  }

  Future<void> openAppSettings() {
    return geo.Geolocator.openAppSettings();
  }

  Future<void> openDeveloperOptions() {
    return _mockLocationService.openDeveloperOptions();
  }
}

class PermissionStatusSnapshot {
  const PermissionStatusSnapshot({
    required this.locationServiceEnabled,
    required this.locationPermission,
    required this.mockLocationEnabled,
  });

  final bool locationServiceEnabled;
  final geo.LocationPermission locationPermission;
  final bool mockLocationEnabled;

  bool get hasLocationPermission {
    return locationPermission == geo.LocationPermission.always ||
        locationPermission == geo.LocationPermission.whileInUse;
  }

  bool get ready {
    return locationServiceEnabled &&
        hasLocationPermission &&
        mockLocationEnabled;
  }
}
