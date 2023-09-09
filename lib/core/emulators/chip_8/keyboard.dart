import 'package:flutter/material.dart';

import '../../utils/wrapper.dart';
import '../base/keyboard.dart';

class Chip8KeyBoard extends EmulatorKeyboard<Chip8Key> {
  Chip8KeyBoard({
    super.key,
  });

  final Wrapper<Chip8Key> pressedKey = Wrapper();

  final Wrapper<Chip8Key> releasedKey = Wrapper();

  @override
  void onKeyDown(Chip8Key key) {
    pressedKey.content = key;
    releasedKey.content = null;
    super.onKeyDown(key);
  }

  @override
  void onKeyUp(Chip8Key key) {
    releasedKey.content = key;
    pressedKey.content = null;
    super.onKeyUp(key);
  }

  @override
  List<Chip8Key> get keys => Chip8Key.values;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      padding: const EdgeInsets.symmetric(horizontal: 100),
      crossAxisCount: 4,
      shrinkWrap: true,
      children: List.generate(
        keys.length,
        (index) {
          final Chip8Key key = keys.elementAt(index);

          return InkWell(
            borderRadius: BorderRadius.circular(8),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Text(key.label),
              ),
            ),
            onTapDown: (_) => onKeyDown(key),
            onTapUp: (_) => onKeyUp(key),
          );
        },
      ),
    );
  }
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
