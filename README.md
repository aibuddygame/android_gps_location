# GPS Location Changer

Android QA utility for injecting mock GPS coordinates on your own test device. It is intended for legitimate app testing, not for bypassing app rules or misleading services.

## Features

- Manual latitude and longitude entry.
- Optional accuracy, speed, bearing, and update interval.
- Start/stop mock-location sessions.
- Timer-based continuous updates.
- Android foreground service with persistent notification for background operation.
- Setup guidance for location permissions, device location, and Developer Options.
- Built-in and saved presets.
- Live debug/status display.

## Android Setup

1. Enable Developer Options on the Android test device.
2. Open **Developer Options** and select this app under **Select mock location app**.
3. Enable device location services.
4. Launch the app and grant location permission.
5. Enter coordinates or choose a preset, then tap **Start mock**.

Android 13+ may also ask for notification permission so the foreground service notification can appear.

## Run

```sh
flutter pub get
flutter run
```

This project is Android-focused because iOS does not expose equivalent mock-location provider APIs for installed apps.

## Architecture

```text
lib/
├── main.dart
├── app.dart
├── core/
├── data/
│   ├── models/
│   ├── repositories/
│   └── services/
├── domain/
│   ├── entities/
│   └── usecases/
├── presentation/
│   ├── screens/
│   ├── widgets/
│   └── providers/
└── services/
    └── mock_location_service.dart
```

- `MockLocationService` uses a Flutter method channel to start/stop the native Android foreground service.
- `MockLocationForegroundService` owns the `LocationManager` test provider and posts repeated updates.
- `LocationRepository` persists presets and the last session in `SharedPreferences`.
- `DashboardProvider` centralizes UI state, validation, permission checks, and session state.

## Important Limits

- The app must be selected as the mock-location app in Developer Options or Android will reject test-provider updates.
- Some OEM Android builds restrict background work aggressively. Keep battery optimization rules in mind during long tests.
- `ACCESS_MOCK_LOCATION` is declared for legacy visibility, but modern Android controls mock capability through Developer Options/AppOps.

## Next Improvements

- Route playback from GPX/KML files.
- Joystick-style manual movement.
- Profiles for repeated test scenarios.
- Randomized jitter and walking/driving simulation modes.
- Export/import preset collections.
- More detailed service restart recovery after process death.
