import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Create the directory if it doesn't exist
  final directory = Directory('assets/icons');
  if (!await directory.exists()) {
    await directory.create(recursive: true);
  }
  
  // Generate the icon
  final image = await generateTShapedIcon(512);
  
  // Save the icon
  final file = File('assets/icons/tetris_icon.png');
  await file.writeAsBytes(image);
  
  print('T-shaped icon saved to assets/icons/tetris_icon.png');
  exit(0);
}

Future<Uint8List> generateTShapedIcon(int size) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  
  // Size of each block
  final blockSize = size / 3;
  
  // Create a paint object with cyan color and a border
  final paint = Paint()
    ..color = const Color(0xFF00CED1) // Turquoise color
    ..style = PaintingStyle.fill;
    
  final borderPaint = Paint()
    ..color = const Color(0xFF008B8B) // Darker turquoise
    ..style = PaintingStyle.stroke
    ..strokeWidth = size * 0.02;
  
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
  
  // Convert to an image
  final picture = recorder.endRecording();
  final img = await picture.toImage(size, size);
  final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
  
  return byteData!.buffer.asUint8List();
} 