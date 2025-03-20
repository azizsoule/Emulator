import 'package:flutter/material.dart';

class Chip8Display extends StatelessWidget {
  final List<bool> display;
  final double scale;
  final Color pixelColor;
  final bool showGrid;
  final double gridOpacity;

  const Chip8Display({
    super.key,
    required this.display,
    this.scale = 10.0,
    this.pixelColor = Colors.green,
    this.showGrid = false,
    this.gridOpacity = 0.3,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: CustomPaint(
        painter: Chip8DisplayPainter(
          display,
          pixelColor: pixelColor,
          showGrid: showGrid,
          gridOpacity: gridOpacity,
        ),
        size: Size(64 * scale, 32 * scale),
      ),
    );
  }
}

class Chip8DisplayPainter extends CustomPainter {
  final List<bool> display;
  final Color pixelColor;
  final bool showGrid;
  final double gridOpacity;

  Chip8DisplayPainter(
    this.display, {
    this.pixelColor = Colors.green,
    this.showGrid = false,
    this.gridOpacity = 0.3,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint pixelPaint = Paint()..color = pixelColor;
    final Paint gridPaint = Paint()
      ..color = Colors.grey.withOpacity(gridOpacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    final double pixelWidth = size.width / 64;
    final double pixelHeight = size.height / 32;

    // Draw pixels
    for (int y = 0; y < 32; y++) {
      for (int x = 0; x < 64; x++) {
        if (display[y * 64 + x]) {
          canvas.drawRect(
            Rect.fromLTWH(
              x * pixelWidth,
              y * pixelHeight,
              pixelWidth,
              pixelHeight,
            ),
            pixelPaint,
          );
        }
      }
    }

    // Draw grid
    if (showGrid) {
      // Vertical lines
      for (int x = 0; x <= 64; x++) {
        canvas.drawLine(
          Offset(x * pixelWidth, 0),
          Offset(x * pixelWidth, size.height),
          gridPaint,
        );
      }
      // Horizontal lines
      for (int y = 0; y <= 32; y++) {
        canvas.drawLine(
          Offset(0, y * pixelHeight),
          Offset(size.width, y * pixelHeight),
          gridPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(Chip8DisplayPainter oldDelegate) =>
      true || oldDelegate.showGrid != showGrid;
} 