import 'package:flutter/material.dart';

import '../../utils/wrapper.dart';
import '../base/keyboard.dart';

class Chip8KeyBoard extends EmulatorKeyboard<Chip8Key> {
  Chip8KeyBoard({
    super.key,
    required super.controller,
  });

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }

  final DataWrapper<Chip8Key> pressedKey = DataWrapper();

  final DataWrapper<Chip8Key> releasedKey = DataWrapper();

  @override
  void onKeyDown(Chip8Key key) {
    pressedKey.data = key;
    releasedKey.data = null;
    super.onKeyDown(key);
  }

  @override
  void onKeyUp(Chip8Key key) {
    releasedKey.data = key;
    pressedKey.data = null;
    super.onKeyUp(key);
  }

  @override
  List<Chip8Key> get keys => Chip8Key.values;
}

enum Chip8Key {
  one._(0x1, "1"),
  two._(0x2, "2"),
  three._(0x3, "3"),
  c._(0xC, "C"),
  four._(0x4, "4"),
  five._(0x5, "5"),
  six._(0x6, "6"),
  d._(0xd, "D"),
  seven._(0x7, "7"),
  eight._(0x8, "8"),
  nine._(0x9, "9"),
  e._(0xE, "E"),
  a._(0xA, "A"),
  zero._(0x0, "0"),
  b._(0xB, "B"),
  f._(0xF, "F");

  final int code;
  final String label;

  const Chip8Key._(this.code, this.label);
}
