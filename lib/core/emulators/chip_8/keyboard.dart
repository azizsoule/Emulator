import 'package:flutter/material.dart';

import '../base/keyboard.dart';

class Chip8KeyBoard extends EmulatorKeyboard {
  const Chip8KeyBoard({
    super.key,
    required super.controller,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }

  @override
  // TODO: implement keys
  List<EmulatorKey> get keys => throw UnimplementedError();
}
