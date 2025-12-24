# Weather Vista - App Name & Launcher Icon Update Plan

## Information Gathered:
- **Current app name**: "simple_weather" (in AndroidManifest.xml)
- **Target app name**: "Weather Vista" 
- **Launcher icon**: Already configured at `assets/launcher/app_icon.png`
- **flutter_launcher_icons**: Already properly configured in pubspec.yaml
- **UI assets**: Located in `assets/images/` (will remain untouched)
- **Assets structure**: Already follows the required structure

## Plan:
### Step 1: Update AndroidManifest.xml ✅ COMPLETED
- Change `android:label="simple_weather"` to `android:label="Weather Vista"`
- This affects the app name when installed on Android devices

### Step 2: Verify flutter_launcher_icons Configuration
- Current configuration in pubspec.yaml is already correct
- Points to `assets/launcher/app_icon.png` for launcher icon
- No changes needed to pubspec.yaml

### Step 3: Generate Launcher Icons & Build APK
- Run `flutter pub get` to ensure dependencies are updated
- Run `dart run flutter_launcher_icons` to generate launcher icons
- Run `flutter build apk --release` to create the release APK

## Dependent Files to be Edited:
- `android/app/src/main/AndroidManifest.xml` (change app name)

## Followup Steps:
1. Install the generated APK on an Android device
2. Verify the app shows as "Weather Vista" 
3. Verify the custom launcher icon appears (not Flutter logo)
4. Launch the app to ensure all UI icons still display correctly

## Expected Results:
- App name: "Weather Vista" (when installed)
- Launcher icon: Custom icon from `assets/launcher/app_icon.png`
- All UI icons remain intact and visible
- No changes to Flutter widgets or UI layout

## Why This Works:
- The flutter_launcher_icons package generates proper Android launcher icons from the specified asset
- The AndroidManifest.xml change only affects the display name, not the internal app ID
- UI icons in assets/images/ are separate from launcher icons
