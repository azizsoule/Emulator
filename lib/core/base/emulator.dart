import 'dart:io';

import 'package:emulator/core/base/cpu.dart';
import 'package:emulator/core/base/keyboard.dart';
import 'package:emulator/core/base/screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

abstract class Emulator<CPU extends EmulatorCPU, SCREEN extends EmulatorScreen, KEYBOARD extends EmulatorKeyboard> extends StatelessWidget {
  final CPU cpu;
  final SCREEN screen;
  final KEYBOARD keyboard;

  const Emulator({
    super.key,
    required this.cpu,
    required this.screen,
    required this.keyboard,
  });

  @protected
  void pickFile() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result?.files.isNotEmpty == true) {
      final File file = File(result!.files.elementAt(0).path ?? "");
      cpu.reset();
      cpu.loadProgram(file.readAsBytesSync());
      cpu.cycle();
    }
  }
}
