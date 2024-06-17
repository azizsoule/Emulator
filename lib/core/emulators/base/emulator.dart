import 'dart:io';

import 'package:emulator/core/emulators/base/keyboard.dart';
import 'package:emulator/core/emulators/base/screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

abstract class Emulator<CPU, MEM, SCREEN extends EmulatorScreen, KEYBOARD extends EmulatorKeyboard> extends StatelessWidget {
  final CPU cpu;
  final MEM memory;
  final SCREEN screen;
  final KEYBOARD keyboard;

  Emulator({
    super.key,
    required this.cpu,
    required this.memory,
    required this.screen,
    required this.keyboard,
  }) {
    keyboard.controller.stream.listen(_keyboardEventListener);
  }

  int get cyclesPerSecond;

  void _keyboardEventListener(EmulatorKeyboardEvent event) {
    if (event.state.isPressed) {
      onKeyPressed(event.key);
    } else {
      onKeyReleased(event.key);
    }
  }

  void loadProgram(List<int> program);

  void pickFile() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result?.files.isNotEmpty == true) {
      final File file = File(result!.files.elementAt(0).path ?? "");

      reset();
      loadProgram(file.readAsBytesSync());
      cycle();
    }
  }

  int fetch();

  Object decode(int opcode);

  void execute(Object object);

  void cycle() {
    final int opcode = fetch();
    final Object object = decode(opcode);
    execute(object);

    Future.delayed(
      Duration(milliseconds: 1000 ~/ cyclesPerSecond),
      cycle,
    );
  }

  void reset();

  void onKeyPressed(key) {}

  void onKeyReleased(key) {}
}
