# App Store Screenshots

## Required Sizes

| Folder | Device | Resolution | Required |
|---|---|---|---|
| `iphone_6.7/` | iPhone 15 Pro Max | 1290 x 2796 | YES |
| `iphone_6.5/` | iPhone 11 Pro Max | 1242 x 2688 | YES |
| `ipad_12.9/` | iPad Pro 12.9" | 2048 x 2732 | YES |

## Screenshots to capture (5 per device)

1. `01_menu.png` — Main menu with DON'T TOUCH RED title
2. `02_gameplay_easy.png` — Gameplay at Level 1-2
3. `03_gameplay_intense.png` — Gameplay at Level 5+ with combo
4. `04_slowmo.png` — Yellow tile active, slow-motion effect
5. `05_gameover.png` — Game Over screen with score

## How to capture

On Mac with Xcode Simulator:
```bash
flutter run -d "iPhone 15 Pro Max"
# Press Cmd+S in Simulator to save screenshot
```

On real device:
- Side button + Volume Up
- AirDrop to Mac

## Note
Files in `dev/` are development screenshots (not for App Store).
