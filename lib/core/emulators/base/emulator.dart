import 'package:emulator/core/emulators/base/keyboard.dart';
import 'package:emulator/core/emulators/base/screen.dart';
import 'package:flutter/material.dart';

abstract class Emulator<C, M, S extends EmulatorScreen, K extends EmulatorKeyboard> extends StatelessWidget {
  final C cpu;
  final M memory;
  final S screen;
  final K keyboard;

  Emulator({
    super.key,
    required this.cpu,
    required this.memory,
    required this.screen,
    required this.keyboard,
  }) {
    _listenKeyboard();
  }

  void _listenKeyboard() {
    keyboard.controller.stream.listen(
      (event) {
        if (event.state.isPressed) {
          onKeyPressed(event.key);
        } else {
          onKeyReleased(event.key);
        }
      },
    );
  }

  void loadProgram(List<int> program);

  int fetch();

  Object decode(int opcode);

  void execute(Object object);

  void cycle() {
    final int opcode = fetch();
    final Object object = decode(opcode);
    execute(object);
  }

  void onKeyPressed(key) {}

  void onKeyReleased(key) {}
}
