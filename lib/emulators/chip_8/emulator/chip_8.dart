import 'dart:typed_data';

import 'package:emulator/core/base/emulator.dart';
import 'package:emulator/emulators/chip_8/emulator/screen.dart';
import 'package:flutter/material.dart';

import 'cpu.dart';
import 'keyboard.dart';

class Chip8Emulator extends Emulator<Chip8CPU, Chip8Screen, Chip8KeyBoard> {
  Chip8Emulator({
    super.key,
  }) : super(
          cpu: Chip8CPU(
            memory: Uint8List(4096),
          ),
          screen: Chip8Screen(scale: 5),
          keyboard: Chip8KeyBoard(),
        );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("CHIP 8"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          screen,
          const SizedBox(
            height: 16,
          ),
          keyboard,
          const SizedBox(
            height: 16,
          ),
          TextButton(
            onPressed: pickFile,
            child: const Text("Charger une ROM"),
          ),
        ],
      ),
    );
  }
}
