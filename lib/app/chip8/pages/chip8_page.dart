import 'package:emulator/app/chip8/widgets/chip8_keyboard.dart';
import 'package:emulator/app/chip8/widgets/chip8_screen.dart';
import 'package:flutter/material.dart';

class Chip8Page extends StatelessWidget {
  const Chip8Page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chip 8"),
      ),
      body: Column(
        children: const [
          Chip8ScreenWidget(),
          Divider(),
          Chip8KeyboardWidget(),
        ],
      ),
    );
  }
}
