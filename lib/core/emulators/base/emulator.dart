import 'dart:io';

import 'package:emulator/core/emulators/base/keyboard.dart';
import 'package:emulator/core/emulators/base/screen.dart';
import 'package:file_picker/file_picker.dart';
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
    keyboard.controller.stream.listen(keyboardEventListener);
  }

  int get cyclesPerSecond;

  void keyboardEventListener(EmulatorKeyboardEvent event) {
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
