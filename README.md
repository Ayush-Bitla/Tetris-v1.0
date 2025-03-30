# Flutter Tetris Game

[Tetris](https://harddrop.com/wiki/Gameplay_overview) implementation
with [SRS](https://harddrop.com/wiki/SRS)
and [wall kicks](https://harddrop.com/wiki/SRS#Wall_Kicks)
. [Try it](https://ayush-bitla.github.io/Tetris/).

This is a simple Tetris game built purely in Flutter, without using any third-party packages. The game consists of a grid where Tetromino pieces appear and fall. The player can move and rotate the pieces to fit them together. The goal is to create full horizontal lines, which will then clear and grant points.

## 📌 Features
- Tetromino pieces appear and fall
- Move and rotate pieces
- Clear full horizontal lines
- Score tracking

## 🚀 Getting Started

### Prerequisites
Make sure you have Flutter installed. You can check by running:
```sh
flutter --version
```
If not installed, follow the official guide: [Flutter Installation](https://flutter.dev/docs/get-started/install)

### Installation
1. Clone this repository:
   ```sh
   git clone https://github.com/your-username/flutter-tetris.git
   ```
2. Navigate to the project directory:
   ```sh
   cd flutter-tetris
   ```
3. Run the project:
   ```sh
   flutter run
   ```

## 🛠️ Code Structure

### 1️⃣ Imports
This game is built purely in Flutter, using only basic Dart packages.

![Imports](assets/code/imports.png)

### 2️⃣ Game Board
The game board dimensions are defined by `rowLength` and `colLength`. The `gameBoard` is a 2D list representing the game grid.

![Game Board Dimensions](assets/code/dimensions.png)

### 3️⃣ Variables
- `currentPiece`: The active Tetromino piece.
- `score`: The player's score.
- `gameOver`: Boolean to check if the game has ended.
- `tetrominoColors`: Colors of the Tetromino pieces (modifiable).

![Variables](assets/code/variables.png)

### You can change the colors of the pieces here if you like!

![Tetromino Colors](assets/code/colors.png)

### 4️⃣ Start Game
- `initState()`: Called when the game starts.
- `startGame()`: Initializes the game loop.

![Start Game](assets/code/start.png)

### 5️⃣ Game Loop
Uses the `dart:math` package to implement a timer that updates the game at regular intervals.

![Game Loop](assets/code/gameloop.png)

### 6️⃣ Player Controls
Methods to control the pieces:
- `moveLeft()`: Moves the piece left.
- `moveRight()`: Moves the piece right.
- `rotatePiece()`: Rotates the piece.

### 7️⃣ UI
The `build()` method constructs the game UI:
- Grid display
- Score counter
- Control buttons

[![Gameplay Demo](assets/code/Tetris.gif)](https://ayush-bitla.github.io/Tetris/)

## 📜 License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**Hope you enjoy the code and the game! Leave a ⭐ if you like it!** 🚀

# Tetris v1.0

A classic Tetris game built with Flutter.

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

### Keyboard
- Arrow Left/Right: Move piece
- Arrow Up: Rotate piece
- Arrow Down: Soft drop
- Space: Hard drop

### Touch (Mobile)
- Swipe Left/Right: Move piece
- Tap: Rotate piece
- Swipe Down: Hard drop

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
