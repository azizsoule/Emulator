import 'package:flutter/material.dart';

import '../base/screen.dart';

class SetPixelEvent extends EmulatorScreenEvent {
  final int x;
  final int y;
  final int value;

  SetPixelEvent({
    required this.x,
    required this.y,
    required this.value,
  });
}

class Chip8Screen extends EmulatorScreen {
  Chip8Screen({
    super.key,
    super.width = 64,
    super.height = 32,
    super.scale,
  });

  @override
  EmulatorScreenState createState() => Chip8ScreenState();

  void turnOnPixel(int x, int y) {
    controller.add(
      SetPixelEvent(
        x: x,
        y: y,
        value: 1,
      ),
    );
  }

  void turnOffPixel(int x, int y) {
    controller.add(
      SetPixelEvent(
        x: x,
        y: y,
        value: 0,
      ),
    );
  }
}

class Chip8ScreenState extends EmulatorScreenState {
  late final List<List<int>> pixels;

  @override
  void initState() {
    super.initState();
    pixels = List.generate(
      widget.width.toInt(),
      (index) => List.filled(widget.height.toInt(), 0),
    );
  }

  @override
  screenEventsListener(EmulatorScreenEvent event) {
    super.screenEventsListener(event);
    if (event is SetPixelEvent) {
      setState(() {
        pixels[event.x][event.y] = event.value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(
        (widget.width * widget.scale).toDouble(),
        (widget.height * widget.scale).toDouble(),
      ),
      painter: Chip8ScreenPainter(
        scale: widget.scale,
        pixels: pixels,
      ),
    );
  }
}

class Chip8ScreenPainter extends CustomPainter {
  final int scale;
  final List<List<int>> pixels;

  Chip8ScreenPainter({
    required this.scale,
    required this.pixels,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint pixelPainter = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    for (int x = 0; x < size.width / scale; x++) {
      for (int y = 0; y < size.height / scale; y++) {
        pixelPainter.color = pixels[x][y] == 1 ? Colors.green : Colors.black;

        final Rect pixel = Rect.fromPoints(
          Offset(
            (x * scale).toDouble(),
            (y * scale).toDouble(),
          ),
          Offset(
            ((x + 1) * scale).toDouble(),
            ((y + 1) * scale).toDouble(),
          ),
        );

        canvas.drawRect(pixel, pixelPainter);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
