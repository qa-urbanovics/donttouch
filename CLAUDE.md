# Don't Touch Red - Project Instructions

## Overview
Mobile reflex game built with Flutter. Developed on Windows, published to App Store via Mac.

## Tech
- Flutter (Dart), no game engine
- Game loop via `Ticker` at 60fps
- State managed locally in StatefulWidgets (no Riverpod/Bloc needed for this scale)
- `SharedPreferences` for persistence

## Architecture
- `lib/game/game_engine.dart` - Pure Dart game logic, no Flutter dependencies. Testable standalone.
- `lib/game/tile.dart` - Data model for tiles
- `lib/screens/` - Three screens: menu, game, game over
- `lib/widgets/game_board.dart` - Rendering layer, translates engine state to widgets
- `lib/services/` - Platform services (scores, haptics)
- `lib/theme/` - Visual constants

## Key Design Decisions
- Game engine is decoupled from rendering (engine has no Flutter imports)
- Tiles use time-based lifecycle (age/lifetime), not frame-based
- Escalation via speed multiplier that increases every 5 seconds
- Combo system: consecutive green taps multiply score
- Grid is 4 columns x 5 rows

## Game Balance Constants (in game_engine.dart)
- `baseSpawnInterval`: 1.2s between tile spawns
- `baseTileLifetime`: 2.5s before tile expires
- `speedIncreaseInterval`: 5s per level
- `speedMultiplierStep`: 0.12 (12% faster per level)
- Green/Red/Yellow ratios change per level tier

## Conventions
- No state management library - direct setState
- Colors defined in `AppColors` class
- All durations in seconds (doubles) in engine, milliseconds in Flutter widgets
- Portrait-only orientation

## Testing on Windows
```bash
flutter run -d chrome
```

## Building for iOS
See PUBLISH_IOS.md
