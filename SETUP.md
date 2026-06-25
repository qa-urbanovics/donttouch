# Don't Touch Red - Setup

## 1. Install Flutter on Windows

Download: https://docs.flutter.dev/get-started/install/windows/mobile

After install, run:
```bash
flutter doctor
```

## 2. Initialize platform files

Open terminal in project directory and run:
```bash
flutter create --project-name dont_touch_red --org com.donttouchred .
```

This will generate android/, ios/, windows/ directories without overwriting our code.

## 3. Install dependencies

```bash
flutter pub get
```

## 4. Run on Windows (for testing)

```bash
flutter run -d windows
```

## 5. Build for iOS (on Mac only)

Transfer project to Mac, then:
```bash
flutter build ios --release
```

Open `ios/Runner.xcworkspace` in Xcode to sign and publish.
