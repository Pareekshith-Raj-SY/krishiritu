# KrishiRitu AI — Smart Farmer Season Guide

A Flutter application for Karnataka farmers providing personalized crop recommendations,
seasonal planning, budget analysis, and farm management tools.

## Quick Start

### Prerequisites
- Flutter SDK ≥ 3.24.0
- Android Studio / VS Code
- Java 11+
- Android SDK (API 21+)

### Setup

```bash
# 1. Clone / extract the project
cd krishiritu

# 2. Copy env template
cp .env.example .env
# Edit .env with your Supabase and API keys (all optional for demo mode)

# 3. Install dependencies
flutter pub get

# 4. Run on connected device or emulator
flutter run

# 5. Build release APK
flutter build apk --release
# APK: build/app/outputs/flutter-apk/app-release.apk

# 6. Build debug APK (faster, for testing)
flutter build apk --debug
# APK: build/app/outputs/flutter-apk/app-debug.apk
```

### Running on Windows
1. Install Flutter: https://docs.flutter.dev/get-started/install/windows
2. Install Android Studio + Android SDK
3. Run `flutter doctor` and resolve any issues
4. Open the project in VS Code or Android Studio
5. Connect an Android device (USB debugging enabled) or start an emulator
6. Run `flutter run` or use the Run button

## Configuration

All external integrations are optional. The app runs fully in demo mode without any keys.

### .env file
```
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
OPENWEATHER_API_KEY=your-key         # Optional: live weather
ANTHROPIC_API_KEY=your-key           # Optional: AI assistant
```

### Supabase Setup
1. Create project at https://supabase.com
2. Run `supabase/migrations/001_initial_schema.sql` in SQL Editor
3. Run `supabase/seed.sql` to populate crop data
4. Copy URL and anon key to .env

## Features

| Feature | Status | Notes |
|---------|--------|-------|
| Crop Recommendations | ✅ Full | Local Karnataka data |
| Farm Season Twin | ✅ Full | Task calendar per crop |
| What-If Simulator | ✅ Full | Offline calculations |
| Budget Explorer | ✅ Full | Input/output calculator |
| Season Memory | ✅ UI | Needs Supabase for storage |
| Crop Health ID | ✅ UI | Needs AI key for photo analysis |
| Weather | ✅ UI | Needs OpenWeather key |
| Nearby Services | ✅ UI | Sample Mysuru data |
| Kannada Language | ✅ Full | Toggle in Settings |
| Supabase Auth | ✅ Full | Demo mode if unconfigured |
| Offline Mode | ✅ Full | SharedPreferences cache |

## Project Structure

```
lib/
  main.dart              — App entry point
  app.dart               — Root widget + locale provider
  core/
    config/              — AppConfig (env keys, constants)
    theme/               — AppTheme (colors, fonts)
    routing/             — GoRouter configuration
  data/
    models/              — FarmModel, CropModel, ExpenseModel
    repositories/        — CropRepository (local Karnataka data)
  features/
    authentication/      — Splash, Onboarding, Login, Register
    farms/               — Farm setup, profile, provider
    dashboard/           — Main dashboard
    crop_planner/        — Season planner + crop detail
    season_twin/         — Farm Season Twin + task calendar
    scenario_simulator/  — What-If crop simulator
    crop_health/         — Crop & weed identification
    weather/             — Weather + seasonal risk
    budget/              — Budget & profit explorer
    services_map/        — Nearby agricultural services
    season_history/      — Season memory & records
    notifications/       — Tasks & alerts
    settings/            — Language, profile, about
  shared/
    widgets/             — MainShell (bottom nav)
    localization/        — English + Kannada strings
supabase/
  migrations/            — SQL schema
  seed.sql               — Karnataka crop data
test/
  widget_test.dart       — Unit tests for crop logic
```

## Data Sources

Crop data is based on:
- Karnataka State Department of Agriculture (KSDA) Crop Calendar 2023
- ICAR Institute of Millets Research (IIMR)
- University of Agricultural Sciences, Bengaluru and Dharwad
- ICRISAT crop production guides

**All data is illustrative sample data. Verify with your local KVK before farming decisions.**

## Known Limitations

1. Photo-based crop health ID requires Anthropic API key (not included)
2. Live weather requires OpenWeather API key
3. Farm data sync requires Supabase configuration
4. Map view uses sample data; real maps need Google Maps API key
5. Kannada fonts require device Kannada support
6. APK build requires Flutter SDK installed locally

## Next Steps

- [ ] Add Google Maps integration for real nearby services
- [ ] Implement OpenWeather API weather screen
- [ ] Add Supabase realtime sync for farm data
- [ ] Implement push notifications
- [ ] Add more Karnataka districts' specific crop data
- [ ] Add voice guidance in Kannada
- [ ] Add market price integration (AgriStack / eNAM)
