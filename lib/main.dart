import 'package:flutter/material.dart';

import 'emulators/chip8/screens/emulator_screen.dart';

void main() {
  runApp(const EmulatorApp());
}

class EmulatorApp extends StatelessWidget {
  const EmulatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Retro Emulator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
      ),
      home: const EmulatorScreen(),
    );
  }
}
