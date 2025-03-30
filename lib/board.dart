import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tetris/piece.dart';
import 'package:tetris/pixel.dart';
import 'package:tetris/values.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  // current score
  int currentScore = 0;
  
  // high score
  int highScore = 0;

  // game over status
  bool gameOver = false;

  @override
  void initState() {
    super.initState();

    // load high score
    loadHighScore();

    //start game when app starts
    startGame();
  }

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
    currentPiece.initializePiece();

    //frame refresh rate
    Duration frameRate = const Duration(milliseconds: 800);
    gameLoop(frameRate);
  }

  //game Loop
  void gameLoop(Duration frameRate) {
    Timer.periodic(
      frameRate,
      (timer) {
        setState(() {
          // clear lines
          clearLines();

          // check landing
          checkLanding();

          // check if the game is over
          if (gameOver == true) {
            timer.cancel();
            showGameOverDialog();
          }

          //move current piece down
          currentPiece.movePiece(Direction.down);
        });
      },
    );
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

  void createNewPiece() {
    // create a random object to generate random tetromino type
    Random rand = Random();

    // create a new piece with random type
    Tetromino randomType =
        Tetromino.values[rand.nextInt(Tetromino.values.length)];
    currentPiece = Piece(type: randomType);
    currentPiece.initializePiece();

    /*
    
    Since our game over condition is if there is a piece at the top level,
    you want to check if the game is over when you create a new piece
    insted of checking every frame, because new pieces are allowed to go through the top level
    but is there is already a piece in the top level when the new piece is created,
    thn game is over 

    */
    if (isGameOver()) {
      gameOver = true;
    }
  }

  //move left
  void moveLeft() {
    //make sure the move is valid before moving there
    if (!checkCollision(Direction.left)) {
      setState(() {
        currentPiece.movePiece(Direction.left);
      });
    }
  }

// move right
  void moveRight() {
    //make sure the move is valid before moving there
    if (!checkCollision(Direction.right)) {
      setState(() {
        currentPiece.movePiece(Direction.right);
      });
    }
  }

// rotate piece
  void rotatePiece() {
    setState(() {
      currentPiece.rotatePiece();
    });
  }

  // clear lines
  void clearLines() {
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
  }

  // GAME OVER METHOD
  bool isGameOver() {
    // check if any columns is the top row are filled
    for (int col = 0; col < rowLength; col++) {
      if (gameBoard[0][col] != null) {
        return true;
      }
    }

    // if the top row is empty, the game is not over
    return false;
  }

  // Add fast drop functionality
  void fastDrop() {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // Wrap the content in a KeyboardListener to capture keyboard events
      body: SafeArea(
        child: RawKeyboardListener(
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
                      child: GridView.builder(
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
      ),
    );
  }
}
