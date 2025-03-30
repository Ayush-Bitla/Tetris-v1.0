# Tetris v1.0

A classic Tetris game built with Flutter.

[Tetris](https://harddrop.com/wiki/Gameplay_overview) implementation
with [SRS](https://harddrop.com/wiki/SRS)
and [wall kicks](https://harddrop.com/wiki/SRS#Wall_Kicks).

[![Gameplay Demo](assets/code/Tetris-v1.gif)](https://ayush-bitla.github.io/Tetris-v1.0/)

## Play Online

Play the game online at: [https://ayush-bitla.github.io/Tetris-v1.0/](https://ayush-bitla.github.io/Tetris-v1.0/)

## Download

Download the Android APK: [tetris_v1.0.apk](https://github.com/Ayush-Bitla/Tetris-v1.0/raw/main/release/tetris_v1.0.apk)

## Features

- Classic Tetris gameplay
- Ghost piece landing indicator
- Level progression (speed increases with level)
- Score tracking and high score saving
- Responsive design for different screen sizes
- Touch controls for mobile play
- Sound effects for game actions

## Controls

Control Tetrominos with keyboard or gestures.

| Action                  | Key   | Gesture                 |
|-------------------------|-------|-------------------------|
| move right              |   →   | swipe right             |
| move left               |   ←   | swipe left              |
| rotate right            |   D   | tap right               |
| rotate left             |   A   | tap left                |
| hold                    |   ↑   | swipe up                |
| soft drop               |   ↓   | hold and swipe down     |
| hard drop               | SPACE | swipe down              |
| Restart                 | PLAY AGAIN |                    |

## Development

This game was developed using Flutter, allowing it to run on web, Android, and iOS platforms.

### Building from Source

```bash
# Clone the repository
git clone https://github.com/Ayush-Bitla/Tetris-v1.0.git
cd Tetris-v1.0

# Get dependencies
flutter pub get

# Run in debug mode
flutter run

# Build for web
flutter build web --release --base-href '/Tetris-v1.0/' --output docs

# Build for Android
flutter build apk --release
```
## 📜 License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**Hope you enjoy the code and the game! Leave a ⭐ if you like it!** 🚀
