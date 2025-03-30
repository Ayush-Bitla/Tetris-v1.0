import 'package:flutter/material.dart';
import 'package:tetris/board.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const ResponsiveLayout(),
    );
  }
}

class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate the appropriate size based on screen dimensions
          double screenWidth = constraints.maxWidth;
          double screenHeight = constraints.maxHeight;
          
          // Calculate the game width
          double gameWidth = screenWidth < screenHeight 
              ? screenWidth * 0.9  // On portrait screens
              : screenHeight * 0.5; // On landscape screens
              
          // Ensure the game doesn't get too large on big screens
          if (gameWidth > 400) {
            gameWidth = 400;
          }
          
          // Calculate height (approximately 2:1 ratio for Tetris)
          double gameHeight = gameWidth * 2;
          
          return Center(
            child: Container(
              width: gameWidth,
              height: gameHeight,
              padding: EdgeInsets.all(screenWidth > 800 ? 16 : 8),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(10),
              ),
              child: FittedBox(
                fit: BoxFit.contain,
                child: SizedBox(
                  width: gameWidth,
                  height: gameHeight,
                  child: const GameBoard(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}