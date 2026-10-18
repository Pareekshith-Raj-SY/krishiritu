# KrishiRitu AI — Complete Setup Guide

## Step 1: Install Flutter (Windows)

1. Download Flutter SDK from https://docs.flutter.dev/get-started/install/windows
2. Extract to `C:\flutter`
3. Add `C:\flutter\bin` to your PATH
4. Install Android Studio from https://developer.android.com/studio
5. In Android Studio: SDK Manager → install Android SDK 21+
6. Run `flutter doctor` — resolve any red items

## Step 2: Configure the Project

```powershell
# Navigate to project
cd krishiritu

# Copy env template
copy .env.example .env

# Edit .env (optional — app works without any keys)
# SUPABASE_URL=https://your-project.supabase.co
# SUPABASE_ANON_KEY=your-key
# OPENWEATHER_API_KEY=your-key

# Install Flutter dependencies
flutter pub get
```

## Step 3: Run on Device / Emulator

```powershell
# List available devices
flutter devices

# Run debug version (fastest)
flutter run

# Run on specific device
flutter run -d <device-id>
```

## Step 4: Build APK

```powershell
# Debug APK (for testing — no signing required)
flutter build apk --debug
# Output: build\app\outputs\flutter-apk\app-debug.apk

# Release APK (optimized)
flutter build apk --release
# Output: build\app\outputs\flutter-apk\app-release.apk

# Install directly on connected device
flutter install
```

## Step 5: Supabase Setup (Optional)

1. Create free project at https://supabase.com
2. Go to SQL Editor
3. Run `supabase/migrations/001_initial_schema.sql`
4. Run `supabase/seed.sql`
5. Go to Settings → API → copy URL and anon key to `.env`

## What Works Without Any Keys

- All 19 screens with full navigation
- Crop recommendations for all Karnataka districts
- Farm Season Twin with task calendar
- What-If Crop Simulator
- Budget & Profit Explorer
- Season Memory (local storage)
- Kannada / English language toggle
- All weather risk calendars (static data)
- Nearby services (sample Mysuru data)

## What Needs Keys

| Feature | Key Needed |
|---------|-----------|
| Live weather | OPENWEATHER_API_KEY |
| User accounts & sync | SUPABASE_URL + SUPABASE_ANON_KEY |
| AI crop health ID | ANTHROPIC_API_KEY |
| Real map data | Google Maps API Key |

## Running Tests

```powershell
flutter test
```

## Troubleshooting

**flutter: command not found**
→ Add Flutter bin to PATH; restart terminal

**Android SDK not found**
→ Open Android Studio → SDK Manager → install SDK 21+

**Gradle build fails**
→ Ensure Java 11+ is installed; run `flutter doctor --android-licenses`

**App crashes on start**
→ Ensure `.env` file exists (copy from `.env.example`)
→ Check `flutter logs` for error details
