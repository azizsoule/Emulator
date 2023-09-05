import 'package:emulator/core/emulators/base/keyboard.dart';
import 'package:emulator/core/emulators/base/screen.dart';

abstract class Emulator<C, M, S extends EmulatorScreen, K extends EmulatorKeyboard> {
  final C cpu;
  final M memory;
  final S screen;
  final K keyboard;

  Emulator(
    this.cpu,
    this.memory,
    this.screen,
    this.keyboard,
  );

  void loadRom(List<int> rom);

  int fetch();

  void decode();

  void execute(int opcode);
}
