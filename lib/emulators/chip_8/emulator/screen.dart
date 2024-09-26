import 'package:emulator/core/base/messages/cpu_output_messages.dart';
import 'package:emulator/core/base/screen.dart';
import 'package:emulator/core/utils/debug_print.dart';
import 'package:emulator/emulators/chip_8/emulator/messages/cpu_output_messsages.dart';
import 'package:emulator/emulators/chip_8/emulator/shared_memory.dart';
import 'package:flutter/material.dart';

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

  @override
  void onMessage(CPUOutputMessage message) {
    switch (message) {
      case ClearScreenMessage _:
        _clearScreen();
      case UpdatePixelMessage updatePixelMessage:
        _updatePixel(updatePixelMessage);
      default:
        printDebug("Unknown message");
    }
  }

  void _clearScreen() {
    setState(() {
      for (int i = 0; i < widget.pixels.length; i++) {
        for (int j = 0; j < widget.pixels[i].length; j++) {
          widget.pixels[i][j] = 0;
        }
      }
    });
  }

  void _updatePixel(UpdatePixelMessage updatePixelMessage) {
    int x = updatePixelMessage.x;
    int y = updatePixelMessage.y;

    setState(() {
      if (x >= widget.width) {
        x = 0;
      } else if (x < 0) {
        x = widget.width - 1;
      }

      if (y >= widget.height) {
        y = 0;
      } else if (y < 0) {
        y = widget.height - 1;
      }

      widget.pixels[x][y] = widget.pixels[x][y] ^ 1;
    });

    Chip8SharedMemory.updatePixelResponse = widget.pixels[x][y] == 0;
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
