import 'package:flutter/material.dart';

void main() {
  runApp(const IconGeneratorApp());
}

class IconGeneratorApp extends StatelessWidget {
  const IconGeneratorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tetris Icon Generator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyan),
        useMaterial3: true,
      ),
      home: const IconGeneratorScreen(),
    );
  }
}

class IconGeneratorScreen extends StatelessWidget {
  const IconGeneratorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tetris Icon Generator'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Your T-shaped icon:',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(20),
              ),
              child: CustomPaint(
                painter: TShapePainter(),
                size: const Size(200, 200),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Steps to create the app icon:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('1. Save this image as PNG'),
                  Text('2. Place it in your assets/icons folder'),
                  Text('3. Run: flutter pub run flutter_launcher_icons'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TShapePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final blockSize = size.width / 3;
    
    final paint = Paint()
      ..color = const Color(0xFF00CED1) // Turquoise color
      ..style = PaintingStyle.fill;
      
    final borderPaint = Paint()
      ..color = const Color(0xFF008B8B) // Darker turquoise
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.02;
    
    // Draw the T shape (3 blocks on top, 1 in middle, 1 at bottom)
    // Top row
    for (int i = 0; i < 3; i++) {
      final rect = Rect.fromLTWH(i * blockSize, 0, blockSize, blockSize);
      canvas.drawRect(rect, paint);
      canvas.drawRect(rect, borderPaint);
    }
    
    // Middle block
    final middleRect = Rect.fromLTWH(blockSize, blockSize, blockSize, blockSize);
    canvas.drawRect(middleRect, paint);
    canvas.drawRect(middleRect, borderPaint);
    
    // Bottom block
    final bottomRect = Rect.fromLTWH(blockSize, blockSize * 2, blockSize, blockSize);
    canvas.drawRect(bottomRect, paint);
    canvas.drawRect(bottomRect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 