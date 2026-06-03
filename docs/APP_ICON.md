# App Launcher Icon

TravelEase uses [flutter_launcher_icons](https://pub.dev/packages/flutter_launcher_icons) to generate platform launcher icons.

## Quick steps

1. Replace the source image:
   - Path: `assets/icons/app_icon.png`
   - Recommended: **1024×1024** PNG, square, no transparency issues on iOS (or use a solid background).

2. Generate icons:

```bash
flutter pub get
dart run flutter_launcher_icons
```

3. Rebuild the app:

```bash
flutter run
```

## Notes

- Configuration lives in `pubspec.yaml` under `flutter_launcher_icons`.
- Android and iOS icons are updated automatically from the same file.
- If the command fails, confirm `assets/icons/app_icon.png` exists.
