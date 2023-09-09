import 'package:emulator/core/emulators/chip_8/chip_8.dart';
import 'package:flutter/material.dart';

class Chip8Page extends StatelessWidget {
  const Chip8Page({super.key});

  @override
  Widget build(BuildContext context) {
    return Chip8Emulator();
  }
}
