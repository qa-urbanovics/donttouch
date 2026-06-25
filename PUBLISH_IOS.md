# Don't Touch Red — Полная инструкция для публикации в App Store

Эта инструкция описывает ВСЕ шаги, которые нужно выполнить на Mac для сборки и публикации приложения.

---

## Часть 1: Подготовка Mac

### Шаг 1.1 — Установить Xcode
```bash
# Открой Mac App Store и установи Xcode (15+)
# После установки запусти и прими лицензию:
sudo xcodebuild -license accept
xcode-select --install
```

### Шаг 1.2 — Установить Flutter SDK
```bash
git clone https://github.com/flutter/flutter.git -b stable ~/flutter
echo 'export PATH="$HOME/flutter/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
flutter doctor
```
> Flutter doctor покажет что не так. Убедись что iOS toolchain зелёный.

### Шаг 1.3 — Установить CocoaPods
```bash
sudo gem install cocoapods
# Или через Homebrew:
brew install cocoapods
```

### Шаг 1.4 — Apple Developer Account
1. Перейди на https://developer.apple.com/programs/
2. Зарегистрируйся ($99/год)
3. Дождись активации (обычно 24-48 часов)

---

## Часть 2: Получить проект

### Шаг 2.1 — Клонировать репозиторий
```bash
cd ~/Projects
git clone git@github.com:qa-urbanovics/donttouch.git DontTouchRed
cd DontTouchRed
```

### Шаг 2.2 — Установить зависимости
```bash
flutter pub get
cd ios
pod install
cd ..
```

### Шаг 2.3 — Проверить сборку
```bash
flutter doctor
flutter analyze
```

---

## Часть 3: Настройка Xcode

### Шаг 3.1 — Открыть проект
```bash
open ios/Runner.xcworkspace
```
> ВАЖНО: Открывай именно `.xcworkspace`, НЕ `.xcodeproj`

### Шаг 3.2 — Настроить подписание (Signing)
1. В Xcode выбери **Runner** в левой панели (project navigator)
2. Выбери target **Runner**
3. Вкладка **Signing & Capabilities**
4. Поставь галку **Automatically manage signing**
5. Выбери свой **Team** (Apple Developer Account)
6. **Bundle Identifier**: `com.qaurbanovics.donttouchred`
   > Если ID занят, попробуй `com.yourname.donttouchred`

### Шаг 3.3 — Проверить настройки
В Xcode → Runner → General:
- **Display Name**: `Don't Touch Red` (уже настроено в Info.plist)
- **Bundle Identifier**: `com.qaurbanovics.donttouchred`
- **Version**: `1.0.0`
- **Build**: `1`
- **Deployment Target**: `iOS 13.0` (минимум)
- **Device Orientation**: Portrait Only (уже настроено)

---

## Часть 4: Тестирование на устройстве

### Шаг 4.1 — Подключить iPhone по USB
```bash
flutter devices
# Должен показать подключённый iPhone
```

### Шаг 4.2 — На iPhone разрешить разработчика
1. iPhone → Настройки → Основные → Управление устройством
2. Доверять сертификату разработчика

### Шаг 4.3 — Запустить на устройстве
```bash
flutter run -d <device-id> --release
```

### Шаг 4.4 — Протестировать всё
- [ ] Меню загружается, кнопка PLAY работает
- [ ] Обратный отсчёт 3-2-1 со звуком
- [ ] Зелёные плитки — тап даёт очки
- [ ] Красные плитки — тап = Game Over
- [ ] Жёлтые плитки — замедление
- [ ] Комбо-система работает
- [ ] Уровни растут, скорость увеличивается
- [ ] Звуки работают, кнопка mute отключает
- [ ] Пауза работает
- [ ] Game Over экран с анимацией счёта
- [ ] Кнопка Share создаёт карточку и открывает системный share sheet
- [ ] High Score сохраняется между сессиями
- [ ] На iPad экран адаптируется (бОльшая сетка)

---

## Часть 5: Скриншоты для App Store

### Требуемые размеры

| Устройство | Размер (px) | Обязательно |
|---|---|---|
| iPhone 6.7" (15 Pro Max) | 1290 x 2796 | ДА |
| iPhone 6.5" (11 Pro Max) | 1242 x 2688 | ДА |
| iPad Pro 12.9" (6th gen) | 2048 x 2732 | ДА (если iPad) |

### Какие скриншоты нужны (минимум 3, максимум 10)

1. **Меню** — главный экран с заголовком DON'T TOUCH RED
2. **Геймплей (начало)** — Level 1-2, несколько плиток
3. **Геймплей (интенсив)** — Level 5+, много плиток, комбо
4. **Slow-Motion** — жёлтая плитка активна, эффект замедления
5. **Game Over** — экран с рекордом и кнопкой Share

### Как сделать скриншоты

**Вариант A — Через Xcode Simulator:**
```bash
# Запустить на симуляторе нужного устройства:
flutter run -d "iPhone 15 Pro Max"
flutter run -d "iPad Pro (12.9-inch) (6th generation)"

# Скриншот в симуляторе: Cmd+S (сохранит на рабочий стол)
```

**Вариант B — На реальном устройстве:**
- iPhone: боковая кнопка + громкость вверх
- Передать скриншоты на Mac через AirDrop

### Куда складывать
```
screenshots/
├── iphone_6.7/          ← iPhone 15 Pro Max (1290x2796)
│   ├── 01_menu.png
│   ├── 02_gameplay_easy.png
│   ├── 03_gameplay_intense.png
│   ├── 04_slowmo.png
│   └── 05_gameover.png
├── iphone_6.5/          ← iPhone 11 Pro Max (1242x2688)
│   ├── 01_menu.png
│   ├── ...
│   └── 05_gameover.png
└── ipad_12.9/           ← iPad Pro 12.9" (2048x2732)
    ├── 01_menu.png
    ├── ...
    └── 05_gameover.png
```

---

## Часть 6: Сборка Release

### Шаг 6.1 — Собрать iOS release
```bash
flutter build ios --release
```

### Шаг 6.2 — Архивировать в Xcode
1. В Xcode: выбери **Any iOS Device (arm64)** как target
2. Меню: **Product → Archive**
3. Подожди завершения (2-5 минут)
4. Откроется окно **Organizer**

### Шаг 6.3 — Загрузить в App Store Connect
1. В Organizer нажми **Distribute App**
2. Выбери **App Store Connect**
3. Выбери **Upload**
4. Нажми **Next** → **Next** → **Upload**
5. Подожди завершения загрузки

---

## Часть 7: App Store Connect

### Шаг 7.1 — Создать приложение
1. Перейди на https://appstoreconnect.apple.com/
2. Нажми **Apps** → **+** → **New App**
3. Заполни:
   - **Platforms**: iOS
   - **Name**: `Don't Touch Red`
   - **Primary Language**: English (U.S.)
   - **Bundle ID**: выбери из списка (com.qaurbanovics.donttouchred)
   - **SKU**: `donttouchred2026`
   - **User Access**: Full Access

### Шаг 7.2 — Заполнить информацию о приложении

**App Information:**
- **Subtitle**: `Fast Reflex Tile Game`
- **Category**: Games → Casual
- **Content Rights**: Does not contain third-party content
- **Age Rating**: заполни опросник (всё "No" → получишь 4+)

**Pricing and Availability:**
- **Price**: Free
- **Availability**: All territories

### Шаг 7.3 — Заполнить описание (Version Information)

**Название**: Don't Touch Red

**Promotional Text** (до 170 символов):
```
Test your reflexes! Tap green, avoid red. How fast can you go? Infinite levels, increasing speed, zero ads. Challenge your friends!
```

**Description (English)**:
```
How fast are your reflexes? Find out in Don't Touch Red!

Tap the GREEN tiles. Avoid the RED tiles. It sounds simple... but can you survive?

The speed keeps increasing, the tiles keep coming faster, and one wrong tap means GAME OVER. How long can you last?

FEATURES:
- Fast-paced reflex gameplay
- Infinite levels with increasing difficulty
- Combo system for bonus points
- Special slow-motion power-ups (yellow tiles!)
- Stunning neon visual effects and particles
- Responsive design for iPhone and iPad
- Share your high scores with friends
- No ads, no in-app purchases, no data collection

CHALLENGE:
- Level 1-3: Warm up. You got this.
- Level 4-7: Getting tricky. Stay focused.
- Level 8-12: Things are getting intense.
- Level 13+: Only legends survive here.

What's your highest score? Share it and challenge your friends!
```

**Keywords** (до 100 символов):
```
reflex,reaction,tiles,tap,speed,game,casual,neon,fast,arcade,challenge,combo,touch,avoid,red,green
```

**Support URL**:
```
https://github.com/qa-urbanovics/donttouch
```

**Privacy Policy URL**:
```
https://qa-urbanovics.github.io/donttouch/privacy_policy.html
```

**What's New**:
```
Initial release! Fast-paced reflex game with infinite levels, combo system, slow-motion power-ups, and stunning neon visuals.
```

### Шаг 7.4 — Загрузить скриншоты
1. Во вкладке **App Store** → **Version Information**
2. Загрузи скриншоты для каждого размера устройства:
   - **iPhone 6.7" Display** — 5 скриншотов (1290x2796)
   - **iPhone 6.5" Display** — 5 скриншотов (1242x2688)
   - **iPad Pro 12.9" Display** — 5 скриншотов (2048x2732)

### Шаг 7.5 — Выбрать Build
1. Прокрути вниз до секции **Build**
2. Нажми **+** и выбери загруженный билд (из шага 6.3)
3. Подожди пока Apple проверит билд (5-30 минут)

### Шаг 7.6 — App Review Information
- **Contact**: твои имя, фамилия, email, телефон
- **Notes for Reviewer**:
```
This is a simple reflex game. Tap green tiles to score points, avoid red tiles (game over). Yellow tiles trigger a slow-motion effect. The game has no in-app purchases, no advertising, no user accounts, and collects no data. All game data (scores) is stored locally on the device only.
```

### Шаг 7.7 — Отправить на Review
1. Убедись что все секции заполнены (зелёные галки)
2. Нажми **Add for Review**
3. Нажми **Submit to App Review**

---

## Часть 8: После отправки

### Сроки
- Обычно Apple рассматривает за **24-48 часов**
- Первый раз может занять до **7 дней**

### Возможные причины отказа
| Причина | Решение |
|---|---|
| Нет Privacy Policy | Уже есть: `https://qa-urbanovics.github.io/donttouch/privacy_policy.html` |
| Crash on launch | Протестируй на реальном устройстве перед отправкой |
| Minimal functionality | Наша игра имеет достаточно функций |
| Missing screenshots | Загрузи все 3 размера |
| Inappropriate content | У нас нет — рейтинг 4+ |

### Если отказали
1. Прочитай причину в App Store Connect → Resolution Center
2. Исправь проблему
3. Загрузи новый билд (увеличь Build Number в pubspec.yaml)
4. Отправь повторно на Review

---

## Чеклист перед отправкой

- [ ] Apple Developer Account активен и оплачен
- [ ] Xcode 15+ установлен
- [ ] Flutter SDK установлен, `flutter doctor` без ошибок
- [ ] `flutter pub get` и `pod install` прошли успешно
- [ ] Signing настроен (Team + Bundle ID)
- [ ] Приложение протестировано на реальном устройстве
- [ ] App Icon установлен (уже сгенерирован — 15 размеров)
- [ ] Launch Screen тёмный (уже настроен)
- [ ] Ориентация — только portrait (уже настроено)
- [ ] Display Name: "Don't Touch Red" (уже настроено)
- [ ] Скриншоты сделаны: iPhone 6.7", 6.5", iPad 12.9"
- [ ] Privacy Policy опубликована (уже на GitHub Pages)
- [ ] Описание и keywords подготовлены (см. выше)
- [ ] Билд загружен в App Store Connect
- [ ] Все поля в App Store Connect заполнены
- [ ] Отправлено на Review

---

## Быстрый старт (TL;DR)

```bash
# 1. Клонировать
git clone git@github.com:qa-urbanovics/donttouch.git DontTouchRed && cd DontTouchRed

# 2. Зависимости
flutter pub get && cd ios && pod install && cd ..

# 3. Открыть в Xcode, настроить signing
open ios/Runner.xcworkspace

# 4. Тест на устройстве
flutter run --release

# 5. Скриншоты (через симулятор)
flutter run -d "iPhone 15 Pro Max"

# 6. Сборка + архив
flutter build ios --release
# Затем в Xcode: Product → Archive → Distribute App

# 7. App Store Connect — заполнить всё и Submit
```
