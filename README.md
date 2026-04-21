# GPS Location Changer

Phase 1 MVP for an Android mock-location console. The app is intentionally scoped for QA and development on devices you control. It does not include map UI. Search is text-first and backed by Google Places.

## Architecture Summary

The MVP is split into five layers:

- `modules/mock`: session bootstrap, permission checks, background start/stop, location-name resolution.
- `modules/search`: Google Places autocomplete + place-details lookup with a clean service contract.
- `modules/privacy`: first-run consent persistence and settings review.
- `modules/ads`: banner-slot abstraction with a Phase 1 placeholder implementation ready for AdMob or mediation.
- `presentation`: technical dark UI, 3-zone dashboard, consent flow, settings/about, and diagnostics.

The Android foreground service remains the native execution layer for continuous injection while Flutter owns orchestration, consent, search, and UI state.

## Project Structure

```text
lib/
├── app.dart
├── main.dart
├── core/
│   ├── constants/
│   ├── theme/
│   └── utils/
├── modules/
│   ├── ads/
│   ├── mock/
│   ├── privacy/
│   ├── search/
│   └── settings/
├── presentation/
│   ├── controllers/
│   ├── screens/
│   └── widgets/
├── data/
├── domain/
└── services/
```

Notable boundaries:

- `MockLocationForegroundService` and `MainActivity` stay focused on Android-only injection/platform hooks.
- `MvpController` coordinates modules without embedding API or storage logic inside widgets.
- Privacy and settings are persisted separately so Phase 2 features can extend them without coupling to mock-session storage.

## Setup Instructions

1. Install Flutter and Android SDK tooling.
2. Run `flutter pub get`.
3. Provide a Places API key with `--dart-define=GOOGLE_PLACES_API_KEY=YOUR_KEY`.
4. Update the placeholder URLs and support email in `lib/core/constants/app_constants.dart`.
5. On the Android device, enable Developer Options and choose this app under `Select mock location app`.
6. Grant location permission and enable location services when prompted.

Run with:

```sh
flutter run --dart-define=GOOGLE_PLACES_API_KEY=YOUR_KEY
```

## Testing Guide

1. Run `flutter analyze`.
2. Run `flutter test`.
3. On-device, verify the first-run consent flow, settings review, disabled-search consent path, search success/no-results, and start/stop behavior.
4. Validate lifecycle recovery by backgrounding the app while the foreground service is running, then resuming it.
5. Confirm Developer Options, location services, and permission edge states each show the expected setup actions.

## Phase 2 Extension Notes

- Login/cloud sync can attach to the existing `modules/privacy` and `modules/settings` preferences without affecting mock execution.
- Pro monetization can replace `PlaceholderAdsService` or add entitlement-aware implementations behind the same interface.
- Routes, joystick controls, and scenario playback can live under a new `modules/navigation` slice while reusing `MockLocationManager`.
- Search history, saved workspaces, and remote presets can extend the current repositories without changing the dashboard contract.

## Important Limits

- Android must allow this app as the mock-location app or injection will fail.
- Some OEM devices aggressively throttle background work; foreground service operation mitigates but does not eliminate vendor restrictions.
- The repository ships placeholder privacy/contact URLs by default and expects you to replace them before release.
