import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:tetris/piece.dart';
import 'package:tetris/pixel.dart';
import 'package:tetris/values.dart';

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

  // game over status
  bool gameOver = false;

  @override
  void initState() {
    super.initState();

    //start game when app starts
    startGame();
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
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Game Over'),
      content: Text("Your Score is: $currentScore"),
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
        gameBoard[0] = List.generate(row, (index) => null);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          //GAME GRID
          Expanded(
            child: GridView.builder(
              itemCount: rowLength * colLength,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: rowLength),
              itemBuilder: (context, index) {
                //get row and column of each index
                int row = (index / rowLength).floor();
                int col = index % rowLength;

                // current piece
                if (currentPiece.position.contains(index)) {
                  return Pixel(color: currentPiece.color,); //Pixel
                }

                //landed pieces
                else if (gameBoard[row][col] != null) {
                  final Tetromino? tetrominoType = gameBoard[row][col];
                  return Pixel(
                      color: tetrominoColors[tetrominoType]);
                }

                //blank pixel
                else {
                  return Pixel(color: Colors.grey[900]);
                }
              },
            ),
          ),

          // SCORE
          Text(
            'Score:$currentScore',
            style: const TextStyle(color: Colors.white),
          ),

          // GAME CONTROLS
          Padding(
            padding: const EdgeInsets.only(bottom: 50.0, top: 50),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                //left
                IconButton(
                  onPressed: moveLeft,
                  color: Colors.white,
                  icon: const Icon(Icons.arrow_back_ios),
                ),
                //rotate
                IconButton(
                  onPressed: rotatePiece,
                  color: Colors.white,
                  icon: const Icon(Icons.rotate_right),
                ),
                //right
                IconButton(
                  onPressed: moveRight,
                  color: Colors.white,
                  icon: const Icon(Icons.arrow_forward_ios),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
