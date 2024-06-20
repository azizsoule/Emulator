import 'package:flutter/material.dart';

import '../base/screen.dart';

class Chip8Screen extends EmulatorScreen {
  late final List<List<int>> pixels;

  Chip8Screen({
    super.key,
    super.width = 64,
    super.height = 32,
    super.scale,
  }) {
    pixels = List.generate(
      width.toInt(),
      (index) => List.filled(height.toInt(), 0),
    );
  }

  @override
  EmulatorScreenState createState() => _Chip8ScreenState();

  bool updatePixel(int x, int y) {
    if (x >= width) {
      x = 0;
    } else if (x < 0) {
      x = width - 1;
    }

    if (y >= height) {
      y = 0;
    } else if (y < 0) {
      y = height - 1;
    }

    update(() {
      pixels[x][y] = pixels[x][y] ^ 1;
    });

    return pixels[x][y] == 0;
  }

  void clear() {
    update(() {
      for (int i = 0; i < pixels.length; i++) {
        for (int j = 0; j < pixels[i].length; j++) {
          pixels[i][j] = 0;
        }
      }
    });
  }
}

class _Chip8ScreenState extends EmulatorScreenState<Chip8Screen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: CustomPaint(
        size: Size(
          widget.width * widget.scale,
          widget.height * widget.scale,
        ),
        painter: _Chip8ScreenPainter(
          scale: widget.scale,
          pixels: widget.pixels,
        ),
      ),
    );
  }
}

class _Chip8ScreenPainter extends CustomPainter {
  final double scale;
  final List<List<int>> pixels;

  _Chip8ScreenPainter({
    required this.scale,
    required this.pixels,
  });

  Color get _blankColor => const Color(0xFF9A6600);

  Color get _drawColor => const Color(0xFFFFCC01);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint pixelPainter = Paint()
      ..color = _blankColor
      ..style = PaintingStyle.fill;

    for (int x = 0; x < (size.width ~/ scale); x++) {
      for (int y = 0; y < (size.height ~/ scale); y++) {
        pixelPainter.color = pixels[x][y] == 1 ? _drawColor : _blankColor;

        final Rect pixel = Rect.fromPoints(
          Offset(
            x * scale,
            y * scale,
          ),
          Offset(
            (x + 1) * scale,
            (y + 1) * scale,
          ),
        );

        canvas.drawRect(pixel, pixelPainter);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => oldDelegate != this;
}
