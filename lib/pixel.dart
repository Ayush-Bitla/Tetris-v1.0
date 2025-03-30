import 'package:flutter/material.dart';

// ignore: must_be_immutable
class Pixel extends StatelessWidget {
  var color;
  bool isGhost;
 
  Pixel({
    super.key,
    required this.color,
    this.isGhost = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isGhost) {
      // For ghost pieces, use a bordered style
      return Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: color.withOpacity(0.5),
            width: 2,
          ),
        ),
        margin: const EdgeInsets.all(1),
      );
    } else {
      // Regular solid pixel
      return Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4)
        ),
        margin: const EdgeInsets.all(1),
      );
    }
  }
}
