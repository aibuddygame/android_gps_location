# GPS Fake v1.9.0 - Release Notes

**Release Date:** April 22, 2026  
**Status:** Stable Release Candidate  
**Git Tag:** v1.9.0-stable

---

## Overview

GPS Fake is a developer tool for QA testing and mock location simulation on Android devices. This stable release includes all core features, privacy controls, and a polished user experience.

---

## Features

### Core Functionality
- ✅ **Mock Location Control** - Set any GPS coordinates with precision
- ✅ **Background Service** - Runs continuously even when app is closed
- ✅ **Editable Coordinates** - Fine-tune lat/lng after search or manual entry
- ✅ **Real-time Status** - Visual indicators for active/inactive state

### Search & Location
- ✅ **Two-Step Search** - Select country/city first, then search specific locations
- ✅ **Smart Suggestions** - Common cities/regions for quick selection
- ✅ **OpenStreetMap Integration** - Free, no API key required
- ✅ **Scoped Search** - Results filtered by selected region

### History & Presets
- ✅ **Location History** - Auto-saves used locations with use count
- ✅ **Editable History Names** - Rename history items for clarity
- ✅ **Save to Preset** - Convert history items to presets with one tap
- ✅ **Custom Presets** - Save frequently used locations
- ✅ **Edit Presets** - Modify name, latitude, and longitude
- ✅ **Delete Presets** - Remove unwanted presets individually

### Privacy & Safety
- ✅ **First-Run Consent** - Multi-page privacy and safety agreement
- ✅ **Granular Permissions** - Control search and ads independently
- ✅ **Local Data Only** - All data stays on device, no cloud storage
- ✅ **Policy Links** - Privacy Policy, Terms of Service, Safety Notice in Settings

### UI/UX
- ✅ **Dark Console Theme** - Matte black with cyan/purple accents
- ✅ **Glassmorphism Cards** - Modern translucent design
- ✅ **Gradient Buttons** - Visual hierarchy with color coding
- ✅ **Responsive Layout** - Works on various screen sizes
- ✅ **Clear Status Indicators** - Know when mock location is active

---

## Technical Details

### App Info
| Property | Value |
|----------|-------|
| **Package Name** | `com.example.gps_location_changer` |
| **App Name** | GPS Fake |
| **Version** | 1.9.0 |
| **Min SDK** | Android 5.0 (API 21) |
| **Target SDK** | Android 14 (API 34) |
| **APK Size** | ~57 MB |

### Architecture
- **Framework:** Flutter 3.41.4
- **State Management:** Provider
- **Local Storage:** SharedPreferences + SQLite (Drift)
- **Location Services:** Android Mock Location API
- **Search:** OpenStreetMap Nominatim API

### Permissions Required
- `ACCESS_FINE_LOCATION` - For mock location updates
- `ACCESS_COARSE_LOCATION` - For general location access
- `ACCESS_MOCK_LOCATION` - For mock location functionality
- `FOREGROUND_SERVICE` - For background operation
- `FOREGROUND_SERVICE_LOCATION` - For location foreground service
- `INTERNET` - For OpenStreetMap search
- `POST_NOTIFICATIONS` - For service notifications

---

## Build Instructions

```bash
# Clone repository
git clone https://github.com/aibuddygame/android_gps_location.git
cd android_gps_location

# Checkout stable release
git checkout v1.9.0-stable

# Get dependencies
flutter pub get

# Build release APK
flutter build apk --release

# Output location
# build/app/outputs/flutter-apk/app-release.apk
```

---

## Installation

1. Enable "Unknown Sources" in Android settings
2. Enable "Developer Options" on device
3. Install APK: `adb install app-release.apk`
4. Open app and accept consent
5. Go to Developer Options → Select mock location app → Choose "GPS Fake"
6. Return to app and tap START

---

## Version History

| Version | Date | Key Changes |
|---------|------|-------------|
| v1.9.0 | Apr 22, 2026 | Policy links in Settings, stable release |
| v1.8.0 | Apr 22, 2026 | Removed built-in presets |
| v1.7.0 | Apr 22, 2026 | Save-to-preset, edit/delete presets |
| v1.6.0 | Apr 22, 2026 | Two-step search (region → location) |
| v1.5.0 | Apr 22, 2026 | Renamed to GPS Fake, editable coordinates |
| v1.4.x | Apr 22, 2026 | Consent screen fixes |
| v1.4.0 | Apr 21, 2026 | Modern redesign, OpenStreetMap |
| v1.2.0 | Apr 21, 2026 | Editable location names |
| v1.0.0 | Apr 21, 2026 | Initial MVP release |

---

## Known Issues

- None in this stable release

## Future Enhancements (Post-Launch)

- Route simulation (GPX/KML import)
- Movement profiles (walking/cycling/driving)
- Joystick directional controls
- Pro tier monetization

---

## License

Proprietary - For QA testing and development use only.

---

**Ready for Launch** 🚀
