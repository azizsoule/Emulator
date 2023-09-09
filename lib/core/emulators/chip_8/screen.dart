import 'package:flutter/material.dart';

import '../base/screen.dart';

class Chip8Screen extends EmulatorScreen {
  Chip8Screen({
    super.key,
  });

  @override
  EmulatorScreenState createState() => Chip8ScreenState();
}

class Chip8ScreenState extends EmulatorScreenState {
  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 64,
      height: 32,
      child: Placeholder(),
    );
  }
}
