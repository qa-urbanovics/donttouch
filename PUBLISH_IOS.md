# Publishing Don't Touch Red to App Store

## Prerequisites on Mac

1. **macOS** 13+ (Ventura or newer)
2. **Xcode** 15+ from Mac App Store
3. **Apple Developer Account** ($99/year) - https://developer.apple.com/programs/
4. **Flutter SDK** installed on Mac:
   ```bash
   git clone https://github.com/flutter/flutter.git -b stable ~/flutter
   export PATH="$HOME/flutter/bin:$PATH"
   flutter doctor
   ```
5. **CocoaPods**:
   ```bash
   sudo gem install cocoapods
   ```

## Step 1: Transfer Project to Mac

Copy the entire `DontTouchRed/` folder to your Mac (USB, cloud, git, etc).

## Step 2: Install Dependencies

```bash
cd DontTouchRed
flutter pub get
cd ios
pod install
cd ..
```

## Step 3: Configure Signing

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select "Runner" in the project navigator
3. Go to "Signing & Capabilities" tab
4. Select your Team (Apple Developer account)
5. Set Bundle Identifier: `com.donttouchred.dontTouchRed` (or your preferred ID)
6. Xcode will create provisioning profiles automatically

## Step 4: Configure App Info

Edit `ios/Runner/Info.plist` if needed:
- `CFBundleDisplayName`: Don't Touch Red
- `CFBundleName`: DontTouchRed

## Step 5: Set App Icon

Replace icons in `ios/Runner/Assets.xcassets/AppIcon.appiconset/`:
- You need sizes: 20, 29, 40, 60, 76, 83.5, 1024 (in @1x, @2x, @3x variants)
- Use https://www.appicon.co/ to generate all sizes from one 1024x1024 image

## Step 6: Test on Device

Connect an iPhone via USB:
```bash
flutter run -d <device-id>
# or
flutter run --release
```

## Step 7: Build Release

```bash
flutter build ios --release
```

## Step 8: Archive in Xcode

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select "Any iOS Device" as build target
3. Menu: **Product > Archive**
4. Wait for archive to complete
5. In Organizer window, click **"Distribute App"**
6. Select **"App Store Connect"**
7. Follow the wizard, upload to App Store Connect

## Step 9: App Store Connect

1. Go to https://appstoreconnect.apple.com/
2. Click "+" > "New App"
3. Fill in:
   - **Name**: Don't Touch Red
   - **Primary Language**: English
   - **Bundle ID**: select from dropdown
   - **SKU**: donttouchred2026
4. Fill required fields:
   - **Description**:
     ```
     How fast are your reflexes? Tap the green tiles and avoid the red ones!

     Simple rules, endless challenge. Every 5 seconds the speed increases.
     How long can you survive?

     Features:
     - One-tap gameplay
     - Combo scoring system
     - Infinite difficulty levels
     - Beat your high score
     - Haptic feedback
     ```
   - **Keywords**: reflex, reaction, tap, speed, game, tiles, color, fast, arcade, casual
   - **Category**: Games > Casual
   - **Age Rating**: 4+
   - **Screenshots**:
     - iPhone 6.7" (1290 x 2796) - required
     - iPhone 6.5" (1242 x 2688) - required
     - iPad 12.9" (2048 x 2732) - if supporting iPad
5. **Pricing**: Free
6. Upload screenshots from gameplay
7. Submit for Review

## Step 10: Review

- Apple review typically takes 24-48 hours
- Common rejection reasons:
  - Missing privacy policy (add one, even a simple page)
  - Crashes on launch (test on real device first!)
  - Minimal functionality (our game has enough)

## Privacy Policy

Create a simple privacy policy page (can be a Google Doc or GitHub Pages):
```
Privacy Policy for Don't Touch Red

This app does not collect, store, or share any personal data.
All game scores are stored locally on your device.
No analytics or tracking is used.

Contact: your-email@example.com
Last updated: 2026-06-25
```

## Tips

- Test on the oldest supported iPhone (iPhone SE 2nd gen / iOS 16+)
- Take screenshots during actual gameplay for the store listing
- Record a 15-30s gameplay video for App Preview
- Set price to Free for maximum downloads
