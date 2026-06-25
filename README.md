# Don't Touch Red

A fast-paced reflex game for iOS. Tap green tiles, avoid red ones. Simple to learn, impossible to master.

## Gameplay

- A 4x5 grid fills with colored tiles
- **Green** = tap for points
- **Red** = instant game over
- **Yellow** = distraction (appears from level 3+)
- Speed increases every 5 seconds
- Combo system rewards consecutive correct taps

## Features

- Endless difficulty escalation (infinite levels)
- Combo multiplier scoring system
- Local high score tracking
- Haptic feedback on every action
- Screen shake, glow effects, pop-in animations
- 3-2-1 countdown before start
- Instant restart from Game Over screen
- Dark neon visual theme

## Tech Stack

- **Flutter 3.44+** / Dart 3.12+
- **SharedPreferences** for local scores
- **Game loop** via Ticker (60fps)
- No external game engine needed

## Project Structure

```
lib/
  main.dart                  - App entry point
  theme/app_theme.dart       - Neon dark theme, colors
  game/
    tile.dart                - Tile model (green/red/yellow)
    game_engine.dart         - Core game logic, spawning, escalation
  screens/
    menu_screen.dart         - Main menu with stats
    game_screen.dart         - Gameplay with HUD, shake, combo
    game_over_screen.dart    - Results, new record badge
  widgets/
    game_board.dart          - 4x5 grid rendering, tile animations
  services/
    score_service.dart       - Local high scores persistence
    haptic_service.dart      - Vibration feedback
```

## Development (Windows)

```bash
flutter pub get
flutter run -d chrome       # Test in browser
flutter run -d windows      # Test native (requires Visual Studio C++)
```

## Build for iOS (Mac)

See `PUBLISH_IOS.md` for full instructions.

## Roadmap

- [ ] Sound effects (tap, game over, level up)
- [ ] Game Center leaderboard
- [ ] Daily Challenge mode
- [ ] Share score as image
- [ ] Cosmetic skins/themes
- [ ] Rewarded ads for continue

## License

Proprietary. All rights reserved.
