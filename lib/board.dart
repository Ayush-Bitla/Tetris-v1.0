import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tetris/piece.dart';
import 'package:tetris/pixel.dart';
import 'package:tetris/values.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
// import 'package:flutter_vibrate/flutter_vibrate.dart';
// import 'package:shared_preferences/shared_preferences.dart';

/*

  GAME BOARD

  This is a 2x2 grid with null representing an empty space.
  A non empty sapce will have the color to represent the landed pieces

*/

//create game board
List<List<Tetromino?>> gameBoard = List.generate(
  colLength,
  (i) => List.generate(
    rowLength,
    (j) => null,
  ),
);

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  //current tetris piece
  Piece currentPiece = Piece(type: Tetromino.L);
  
  //next tetris piece
  Piece? nextPiece;

  // current score
  int currentScore = 0;
  
  // high score
  int highScore = 0;

  // game over status
  bool gameOver = false;

  // current game level
  int level = 1;

  // is game paused
  bool isPaused = false;

  // Audio players for sound effects
  final AudioPlayer movePlayer = AudioPlayer();
  final AudioPlayer rotatePlayer = AudioPlayer();
  final AudioPlayer dropPlayer = AudioPlayer();
  final AudioPlayer clearLinePlayer = AudioPlayer();
  final AudioPlayer gameOverPlayer = AudioPlayer();
  
  // Haptic feedback availability
  // bool hasVibrator = false;

  @override
  void initState() {
    super.initState();

    // Load high score
    loadHighScore();
    
    // Initialize audio players
    initAudioPlayers();
    
    // Check for haptic feedback support
    // checkHapticFeedbackSupport();

    //start game when app starts
    startGame();
  }
  
  // Initialize audio players
  Future<void> initAudioPlayers() async {
    // Set volume for all players
    movePlayer.setVolume(0.5);
    rotatePlayer.setVolume(0.5);
    dropPlayer.setVolume(0.7);
    clearLinePlayer.setVolume(0.7);
    gameOverPlayer.setVolume(0.8);
    
    // Preload sound assets
    await movePlayer.setSource(AssetSource('sounds/move.wav'));
    await rotatePlayer.setSource(AssetSource('sounds/rotate.wav'));
    await dropPlayer.setSource(AssetSource('sounds/drop.wav'));
    await clearLinePlayer.setSource(AssetSource('sounds/clear.wav'));
    await gameOverPlayer.setSource(AssetSource('sounds/gameover.wav'));
  }
  
  // Check for haptic feedback support
  /*
  Future<void> checkHapticFeedbackSupport() async {
    bool canVibrate = await Vibrate.canVibrate;
    setState(() {
      hasVibrator = canVibrate;
    });
  }
  */
  
  // load high score from local storage
  Future<void> loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      highScore = prefs.getInt('highScore') ?? 0;
    });
  }

  // save high score to local storage
  Future<void> saveHighScore() async {
    if (currentScore > highScore) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('highScore', currentScore);
      setState(() {
        highScore = currentScore;
      });
    }
  }

  void startGame() {
    // Generate the first piece
    currentPiece.initializePiece();
    
    // Generate the next piece
    _generateNextPiece();

    // Calculate frame rate based on level
    Duration frameRate = Duration(milliseconds: max(100, 800 - ((level - 1) * 100)));
    
    // Start the game loop with the calculated frame rate
    Timer.periodic(
      frameRate,
      (timer) {
        gameLoop(timer);
      },
    );
  }

  // GAME LOOP
  void gameLoop(Timer timer) {
    // Check if the game is over first
    if (gameOver) {
      timer.cancel();
      return;
    }

    setState(() {
      // if the game is paused, don't do anything
      if (isPaused) {
        return;
      }

      // check if any lines are cleared
      clearLines();
      
      // Update level based on score
      // Level up every 5 cleared lines
      int newLevel = (currentScore ~/ 5) + 1;
      if (newLevel != level) {
        level = newLevel;
        // Restart game loop with new frame rate
        timer.cancel();
        startGame();
        return;
      }

      // keep moving the current piece down
      currentPiece.movePiece(Direction.down);

      // check if piece needs to land
      checkLanding();
    });
  }

  // game over message
  void showGameOverDialog() {
    // save high score before showing dialog
    saveHighScore();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Game Over'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Your Score: $currentScore"),
            const SizedBox(height: 8),
            Text("High Score: $highScore", 
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Reset the game
              resetGame();
              Navigator.pop(context);
            },
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }

  // reset game
  void resetGame() {
    // clear the game board
    gameBoard = List.generate(
      colLength,
      (i) => List.generate(
        rowLength,
        (j) => null,
      ),
    );

    // new game
    gameOver = false;
    currentScore = 0;

    // create new piece
    createNewPiece();

    // start game again
    startGame();
  }

  //check for collision in a future position
  //return true -> there is a collision
  //return false -> there is no collision

  // bool checkCollision(Direction direction) {
  //   //loop through each position of the current piece
  //   for (int i = 0; i < currentPiece.position.length; i++) {
  //     //calculate the row and column of the current position
  //     int row = (currentPiece.position[i] / rowLength).floor();
  //     int col = currentPiece.position[i] % rowLength;

  //     //adjust the row and col based on the direction
  //     if (direction == Direction.left) {
  //       col -= 1;
  //     } else if (direction == Direction.right) {
  //       col += 1;
  //     } else if (direction == Direction.down) {
  //       row += 1;
  //     }

  //     // check if the piece is out of the bounds (either too low or too far to the left or right)
  //     if (row >= colLength || col < 0 || col >= rowLength) {
  //       return true;
  //     }
  //   }

  //   //if no collision are detected, return false
  //   return false;
  // }

  bool checkCollision(Direction direction) {
    // loop through all direction index
    for (int i = 0; i < currentPiece.position.length; i++) {
      // calculate the index of the current piece
      int row = (currentPiece.position[i] / rowLength).floor();
      int col = (currentPiece.position[i] % rowLength);

      // directions
      if (direction == Direction.down) {
        row++;
      } else if (direction == Direction.right) {
        col++;
      } else if (direction == Direction.left) {
        col--;
      }

      // check for collisions with boundaries
      if (col < 0 || col >= rowLength || row >= colLength) {
        return true;
      }

      // check for collisions with other landed pieces
      if (row >= 0 && gameBoard[row][col] != null) {
        return true;
      }
    }
    // if there is no collision return false
    return false;
  }

  // void checkLanding() {
  //   // if going down is occupied
  //   if (checkCollision(Direction.down)) {
  //     //mark position as occupied on the gameboard
  //     for (int i = 0; i < currentPiece.position.length; i++) {
  //       int row = (currentPiece.position[i] / rowLength).floor();
  //       int col = currentPiece.position[i] % rowLength;
  //       if (row >= 0 && col >= 0) {
  //         gameBoard[row][col] = currentPiece.type;
  //       }
  //     }

  //     // once landed, create the next piece
  //     createNewPiece();
  //   }
  // }

  void checkLanding() {
    // if going down is occupied or landed on other pieces
    if (checkCollision(Direction.down) || checkLanded()) {
      // mark position as occupied on the game board
      for (int i = 0; i < currentPiece.position.length; i++) {
        int row = (currentPiece.position[i] / rowLength).floor();
        int col = currentPiece.position[i] % rowLength;

        if (row >= 0 && col >= 0) {
          gameBoard[row][col] = currentPiece.type;
        }
      }

      // Check if board is getting too full near the top
      bool topRowsHavePieces = false;
      for (int row = 0; row < 3; row++) {
        for (int col = 0; col < rowLength; col++) {
          if (gameBoard[row][col] != null) {
            topRowsHavePieces = true;
            break;
          }
        }
        if (topRowsHavePieces) break;
      }

      // once landed, create the next piece
      createNewPiece();
    }
  }

  bool checkLanded() {
    // loop through each position of the current piece
    for (int i = 0; i < currentPiece.position.length; i++) {
      int row = (currentPiece.position[i] / rowLength).floor();
      int col = currentPiece.position[i] % rowLength;

      // check if the cell below is already occupied
      if (row + 1 < colLength && row >= 0 && gameBoard[row + 1][col] != null) {
        return true; // collision with a landed piece
      }
    }

    return false; // no collision with landed pieces
  }

  // Generate next random piece
  void _generateNextPiece() {
    Random rand = Random();
    Tetromino randomType = Tetromino.values[rand.nextInt(Tetromino.values.length)];
    nextPiece = Piece(type: randomType);
    nextPiece!.initializePiece();
  }

  // CREATE NEW TETRIS PIECE
  void createNewPiece() {
    // Set current piece to next piece
    if (nextPiece != null) {
      currentPiece = nextPiece!;
    } else {
      // Fallback for first game initialization
      Random rand = Random();
      Tetromino randomType = Tetromino.values[rand.nextInt(Tetromino.values.length)];
      currentPiece = Piece(type: randomType);
      currentPiece.initializePiece();
    }

    // Generate new next piece
    _generateNextPiece();

    // Immediately check if game is over with the new piece
    if (isGameOver()) {
      setState(() {
        gameOver = true;
      });
      
      // Play game over sound
      if (gameOverPlayer != null && _soundEnabled) {
        gameOverPlayer.resume();
      }
      
      // Show game over dialog
      showGameOverDialog();
    }
  }

  //move left
  void moveLeft() {
    //make sure the move is valid before moving there
    if (!checkCollision(Direction.left)) {
      setState(() {
        currentPiece.movePiece(Direction.left);
        
        // Play move sound
        movePlayer.resume();
        
        // Trigger haptic feedback if available
        // if (hasVibrator) {
        //   Vibrate.feedback(FeedbackType.light);
        // }
      });
    }
  }

  // move right
  void moveRight() {
    //make sure the move is valid before moving there
    if (!checkCollision(Direction.right)) {
      setState(() {
        currentPiece.movePiece(Direction.right);
        
        // Play move sound
        movePlayer.resume();
        
        // Trigger haptic feedback if available
        // if (hasVibrator) {
        //   Vibrate.feedback(FeedbackType.light);
        // }
      });
    }
  }

  // rotate piece
  void rotatePiece() {
    setState(() {
      currentPiece.rotatePiece();
      
      // Play rotate sound
      rotatePlayer.resume();
      
      // Trigger haptic feedback if available
      // if (hasVibrator) {
      //   Vibrate.feedback(FeedbackType.medium);
      // }
    });
  }

  // clear lines
  void clearLines() {
    // Track if any lines were cleared in this call
    bool linesCleared = false;
    
    // step 1: Loop through each row of the game board from bottom to top
    for (int row = colLength - 1; row >= 0; row--) {
      //step 2: Initialize a variable tp track if the row is full
      bool rowIsFull = true;

      // step 3: Check if the row is full (all columns in the row are filled with pieces)
      for (int col = 0; col < rowLength; col++) {
        // if there is an empty column, set rowIsFull to false and break the loop
        if (gameBoard[row][col] == null) {
          rowIsFull = false;
          break;
        }
      }

      // step 4: if the row is full, clear the row and shift rows down
      if (rowIsFull) {
        linesCleared = true;
        
        // step 5: move all rows above the cleared row down by one position
        for (int r = row; r > 0; r--) {
          // copy the above row to the current row
          gameBoard[r] = List.from(gameBoard[r - 1]);
        }

        //step 6: set the top row to empty
        gameBoard[0] = List.generate(rowLength, (index) => null);

        //step 7 : Increase the score!
        currentScore++;
      }
    }
    
    // Play sound if any lines were cleared
    if (linesCleared) {
      clearLinePlayer.resume();
      
      // Trigger haptic feedback if available
      // if (hasVibrator) {
      //   Vibrate.feedback(FeedbackType.success);
      // }
    }
  }

  // GAME OVER METHOD
  bool isGameOver() {
    // Check if any cell in top row is filled
    bool topRowOccupied = false;
    for (int col = 0; col < rowLength; col++) {
      if (gameBoard[0][col] != null) {
        topRowOccupied = true;
        break;
      }
    }

    // Also check if top 3 rows have enough filled cells to block new pieces
    int filledCellsInTop3Rows = 0;
    for (int row = 0; row < 3; row++) {
      for (int col = 0; col < rowLength; col++) {
        if (gameBoard[row][col] != null) {
          filledCellsInTop3Rows++;
        }
      }
    }
    
    // If more than half of the cells in top 3 rows are filled, game is likely over
    bool topAreaCongested = filledCellsInTop3Rows > (3 * rowLength) / 2;

    // Check if the current piece overlaps with existing pieces
    bool pieceOverlaps = false;
    for (int i = 0; i < currentPiece.position.length; i++) {
      int row = (currentPiece.position[i] / rowLength).floor();
      int col = currentPiece.position[i] % rowLength;
      
      // Check if position is valid and already occupied
      if (row >= 0 && col >= 0 && row < colLength && col < rowLength) {
        if (gameBoard[row][col] != null) {
          pieceOverlaps = true;
          break;
        }
      }
    }

    return topRowOccupied || pieceOverlaps || topAreaCongested;
  }

  // Fast drop functionality
  void fastDrop() {
    // Play drop sound
    dropPlayer.resume();
    
    // Trigger haptic feedback if available
    // if (hasVibrator) {
    //   Vibrate.feedback(FeedbackType.heavy);
    // }
    
    // Start a timer to drop the piece step by step with animation
    Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (!checkCollision(Direction.down) && !checkLanded()) {
        setState(() {
          currentPiece.movePiece(Direction.down);
        });
      } else {
        // Stop when we hit something
        timer.cancel();
        // Force landing check
        checkLanding();
      }
    });
  }

  // Toggle pause state
  void togglePause() {
    setState(() {
      isPaused = !isPaused;
    });
  }

  // Sound toggle flag
  bool _soundEnabled = true;
  
  // Method to check for lines that need to be cleared
  void checkLinesClear() {
    clearLines();
  }

  // Add method to draw the next piece preview
  Widget _buildNextPiecePreview() {
    if (nextPiece == null) return Container();
    
    // Create a small grid to show the next piece
    // The grid should be a 4x4 grid centered on the piece
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.white24, width: 2),
      ),
      child: GridView.builder(
        padding: const EdgeInsets.all(2),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 16, // 4x4 grid
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 1,
        ),
        itemBuilder: (context, index) {
          // Translate the next piece's position to fit this small preview grid
          List<int> relativePositions = [];
          
          switch (nextPiece!.type) {
            case Tetromino.L:
              relativePositions = [5, 9, 13, 14]; // L shape in a 4x4 grid
              break;
            case Tetromino.J:
              relativePositions = [6, 10, 14, 13]; // J shape
              break;
            case Tetromino.I:
              relativePositions = [4, 5, 6, 7]; // I shape
              break;
            case Tetromino.O:
              relativePositions = [5, 6, 9, 10]; // O shape
              break;
            case Tetromino.S:
              relativePositions = [5, 6, 8, 9]; // S shape
              break;
            case Tetromino.Z:
              relativePositions = [4, 5, 9, 10]; // Z shape
              break;
            case Tetromino.T:
              relativePositions = [5, 8, 9, 10]; // T shape
              break;
            default:
              break;
          }
          
          // Display the piece in the preview
          if (relativePositions.contains(index)) {
            return Pixel(color: tetrominoColors[nextPiece!.type]);
          } else {
            // Use the same pixel style as the main board for consistency
            return Pixel(color: Colors.grey[800]);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Tetris Level $level', 
          style: const TextStyle(color: Colors.white)
        ),
        actions: [
          // Pause/Resume button
          IconButton(
            icon: Icon(isPaused ? Icons.play_arrow : Icons.pause),
            color: Colors.white,
            onPressed: togglePause,
            tooltip: isPaused ? 'Resume' : 'Pause',
          ),
        ],
      ),
      // Wrap the content in a KeyboardListener to capture keyboard events
      body: SafeArea(
        child: Stack(
          children: [
            RawKeyboardListener(
              // Set focus to capture key events
              autofocus: true,
              focusNode: FocusNode(),
              // Handle keyboard events
              onKey: (RawKeyEvent event) {
                if (event is RawKeyDownEvent) {
                  if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
                    moveLeft();
                  } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
                    moveRight();
                  } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                    rotatePiece();
                  } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
                    // Move down once
                    if (!checkCollision(Direction.down)) {
                      setState(() {
                        currentPiece.movePiece(Direction.down);
                      });
                    }
                  } else if (event.logicalKey == LogicalKeyboardKey.space) {
                    // Fast drop with space bar
                    fastDrop();
                  }
                }
              },
              // Wrap with GestureDetector to support touch controls
              child: GestureDetector(
                // Swipe left to move left
                onHorizontalDragEnd: (details) {
                  if (details.primaryVelocity! > 0) {
                    // Swiped right
                    moveRight();
                  } else if (details.primaryVelocity! < 0) {
                    // Swiped left
                    moveLeft();
                  }
                },
                // Swipe up to rotate
                onVerticalDragEnd: (details) {
                  if (details.primaryVelocity! < 0) {
                    // Swiped up
                    rotatePiece();
                  } else if (details.primaryVelocity! > 0) {
                    // Swiped down
                    fastDrop();
                  }
                },
                // Tap to rotate
                onTap: () {
                  rotatePiece();
                },
                child: Column(
                  children: [
                    //GAME GRID
                    Expanded(
                      child: Center(
                        child: AspectRatio(
                          aspectRatio: 2/3,
                          child: Stack(
                            children: [
                              GridView.builder(
                                itemCount: rowLength * colLength,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: rowLength,
                                  childAspectRatio: 1,
                                ),
                                itemBuilder: (context, index) {
                                  //get row and column of each index
                                  int row = (index / rowLength).floor();
                                  int col = index % rowLength;

                                  // current piece
                                  if (currentPiece.position.contains(index)) {
                                    return Pixel(color: currentPiece.color);
                                  }

                                  //landed pieces
                                  else if (gameBoard[row][col] != null) {
                                    final Tetromino? tetrominoType = gameBoard[row][col];
                                    return Pixel(color: tetrominoColors[tetrominoType]);
                                  }

                                  //blank pixel
                                  else {
                                    return Pixel(color: Colors.grey[900]);
                                  }
                                },
                              ),
                              // Next piece display - positioned on the right side
                              Positioned(
                                top: 10,
                                right: 0,
                                child: Container(
                                  width: 100,
                                  padding: const EdgeInsets.all(5.0),
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      const Text(
                                        'NEXT',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      _buildNextPiecePreview(),
                                    ],
                                  ),
                                ),
                              ),
                              // Overlay when game is paused
                              if (isPaused)
                                Container(
                                  color: Colors.black.withOpacity(0.8),
                                  child: const Center(
                                    child: Text(
                                      'PAUSED',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // SCORE and CONTROLS INSTRUCTIONS
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                'Score: $currentScore',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                              Text(
                                'High Score: $highScore',
                                style: const TextStyle(
                                  color: Colors.amber,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                      color: Colors.orangeAccent,
                                      blurRadius: 5,
                                      offset: Offset(0, 0),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          MediaQuery.of(context).size.width > 600
                              ? const Text(
                                  'Keyboard: ←→ to move, ↑ to rotate, ↓ to move down, Space to drop',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                )
                              : const Text(
                                  'Swipe: ←→ to move, ↑ to rotate, ↓ to drop, Tap to rotate',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                        ],
                      ),
                    ),

                    // GAME CONTROLS (visible buttons for mobile/touch)
                    Container(
                      padding: const EdgeInsets.only(bottom: 40.0, top: 10),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Top row for rotation button
                          IconButton(
                            onPressed: rotatePiece,
                            color: Colors.white,
                            iconSize: 30,
                            icon: const Icon(Icons.rotate_right),
                            tooltip: 'Rotate',
                          ),
                          const SizedBox(height: 10),
                          // Bottom row for direction controls
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              //left
                              IconButton(
                                onPressed: moveLeft,
                                color: Colors.white,
                                iconSize: 30,
                                icon: const Icon(Icons.arrow_back_ios),
                                tooltip: 'Move Left',
                              ),
                              const SizedBox(width: 20),
                              //drop
                              IconButton(
                                onPressed: fastDrop,
                                color: Colors.white,
                                iconSize: 30,
                                icon: const Icon(Icons.arrow_downward),
                                tooltip: 'Drop',
                              ),
                              const SizedBox(width: 20),
                              //right
                              IconButton(
                                onPressed: moveRight,
                                color: Colors.white,
                                iconSize: 30,
                                icon: const Icon(Icons.arrow_forward_ios),
                                tooltip: 'Move Right',
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
