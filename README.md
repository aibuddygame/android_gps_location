# GPS Faker

A developer tool for QA testing and mock location simulation on Android devices. GPS Faker allows you to set any GPS coordinates for testing location-based apps without leaving your desk.

## Features

### Core Functionality
- **Mock Location Control** - Set any GPS coordinates with precision
- **Background Operation** - Runs continuously even when app is in background
- **Real Device Location** - Loads your actual GPS coordinates on startup
- **Editable Coordinates** - Fine-tune latitude/longitude after search or manual entry
- **Status Indicator** - Visual feedback showing active/inactive mock location state

### Smart Search
- **Two-Step Search** - Select country/city first, then search specific locations
- **Popular Locations** - Quick-access chips for famous landmarks and hotspots
- **OpenStreetMap Integration** - Free search without API keys
- **Smart Suggestions** - Common cities and regions for quick selection

### History & Presets
- **Location History** - Auto-saves used locations with usage count
- **Editable Names** - Rename history items for easy identification
- **Save to Preset** - Convert history items to presets with one tap
- **Custom Presets** - Save frequently used locations
- **Edit & Delete** - Modify or remove presets as needed

### Privacy & Safety
- **First-Run Consent** - Clear privacy and safety agreements
- **Local Data Only** - All data stays on device, no cloud storage
- **No Account Required** - Use immediately without registration
- **Policy Links** - Privacy Policy, Terms of Service, and Safety Notice accessible in Settings

## Screenshots

```
┌─────────────────────────────────────────┐
│  GPS Faker            🕐  🔖  ⚙️        │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │  ●  READY                       │    │
│  │     Select location to begin    │    │
│  └─────────────────────────────────┘    │
│                                         │
│  Step 1: Select Country or City         │
│  [Search region...              ]       │
│                                         │
│  Step 2: Search Specific Location       │
│  [Search location...            ]       │
│                                         │
│  🔥 Popular in Tokyo, Japan             │
│  [Shibuya] [Tokyo Station] [Shinjuku]   │
│                                         │
│  📍 Current Location                    │
│     35.6762, 139.6503                   │
│                                         │
│  Latitude    Longitude                  │
│  [35.6762 ]  [139.6503]                 │
│                                         │
│  [  START  ]        [  STOP  ]          │
└─────────────────────────────────────────┘
```

## Installation

### Requirements
- Android 5.0 (API 21) or higher
- Location permission
- Developer Options enabled

### Steps
1. Download and install the APK
2. Open the app and accept the privacy consent
3. Go to Settings and complete setup:
   - Grant Location Permission
   - Enable Device Location
   - Set as Mock Location App in Developer Options
4. Return to the app and tap START

## Usage

### Setting a Location
1. **Select Region** - Type a country or city name (e.g., "Tokyo, Japan")
2. **Search Location** - Enter a specific place or tap a popular location chip
3. **Adjust if Needed** - Edit coordinates directly for precise positioning
4. **Tap START** - Begin mock location injection

### Managing Locations
- **History** - View previously used locations (tap 🕐 icon)
- **Presets** - Access saved favorite locations (tap 🔖 icon)
- **Save to Preset** - From History, tap the bookmark icon to save

### Stopping Mock Location
- Tap the **STOP** button in the app, or
- Disable mock location in Developer Options

## Technical Details

### Architecture
- **Framework:** Flutter 3.41.4
- **State Management:** Provider
- **Local Storage:** SharedPreferences + SQLite
- **Location Services:** Android Mock Location API
- **Search:** OpenStreetMap Nominatim API

### Permissions
- `ACCESS_FINE_LOCATION` - For mock location updates
- `ACCESS_MOCK_LOCATION` - For mock location functionality
- `FOREGROUND_SERVICE` - For background operation
- `INTERNET` - For OpenStreetMap search

### Data Privacy
- All location data stored locally on device
- No personal information collected or transmitted
- No account or registration required
- OpenStreetMap queries do not include personal data

## Project Structure

```
lib/
├── core/
│   ├── constants/
│   ├── theme/
│   └── utils/
├── data/
│   ├── models/
│   ├── repositories/
│   └── services/
├── domain/
│   └── entities/
├── presentation/
│   ├── providers/
│   └── screens/
└── services/
```

## Development

### Build from Source
```bash
# Clone repository
git clone https://github.com/aibuddygame/android_gps_location.git
cd android_gps_location

# Get dependencies
flutter pub get

# Build release APK
flutter build apk --release

# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Run in Debug Mode
```bash
flutter run
```

## Important Notes

- This app is for **QA testing and development purposes only**
- Use only on devices you own or have explicit permission to test
- Do not use to deceive location-based services or circumvent security
- Some OEM devices may restrict background services
- Mock location must be enabled in Developer Options for the app to function

## Support

For issues or questions, please check:
- Settings → Privacy Policy
- Settings → Terms of Service
- Settings → Safety Notice

---

**GPS Faker** - Mock location made simple for developers.
