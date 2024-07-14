import 'dart:async';

import 'package:flutter/cupertino.dart';

abstract class EmulatorKeyboard<KEY> extends StatelessWidget {
  EmulatorKeyboard({
    super.key,
  });

  final StreamController<EmulatorKeyboardEvent<KEY>> controller = StreamController<EmulatorKeyboardEvent<KEY>>();

  List<KEY> get keys;

  void onKeyDown(KEY key) {
    controller.add(
      EmulatorKeyboardEvent(
        state: EmulatorKeyState.pressed,
        key: key,
      ),
    );
  }

  void onKeyUp(KEY key) {
    controller.add(
      EmulatorKeyboardEvent(
        state: EmulatorKeyState.released,
        key: key,
      ),
    );
  }
}

enum EmulatorKeyState {
  pressed,
  released;

  bool get isPressed => this == EmulatorKeyState.pressed;

  bool get isReleased => this == EmulatorKeyState.released;
}

class EmulatorKeyboardEvent<KEY> {
  final EmulatorKeyState state;
  final KEY key;

  EmulatorKeyboardEvent({
    required this.state,
    required this.key,
  });
}
