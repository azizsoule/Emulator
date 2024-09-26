import 'package:emulator/emulators/chip_8/emulator/keyboard.dart';

class Chip8SharedMemory {
  static Chip8Key? pressedKey;

  static Chip8Key? releasedKey;

  static bool? updatePixelResponse;

  static void reset() {
    pressedKey = null;
    releasedKey = null;
    updatePixelResponse = null;
  }
}
