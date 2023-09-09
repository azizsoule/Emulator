import 'package:flutter/material.dart';

import '../base/screen.dart';

class Chip8Screen extends EmulatorScreen {
  const Chip8Screen({
    super.key,
  });

  @override
  State<StatefulWidget> createState() => Chip8ScreenController();
}

class Chip8ScreenController extends State<Chip8Screen> {
  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 64,
      height: 32,
      child: Placeholder(),
    );
  }
}
