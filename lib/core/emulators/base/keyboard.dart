import 'dart:async';

import 'package:flutter/cupertino.dart';

abstract class EmulatorKeyboard<K> extends StatelessWidget {
  final StreamController<EmulatorKeyboardEvent<K>> controller;

  const EmulatorKeyboard({
    super.key,
    required this.controller,
  });

  List<K> get keys;

  void onKeyDown(K key) {
    controller.add(
      EmulatorKeyboardEvent(
        state: EmulatorKeyState.pressed,
        key: key,
      ),
    );
  }

  void onKeyUp(K key) {
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

class EmulatorKeyboardEvent<K> {
  final EmulatorKeyState state;
  final K key;

  EmulatorKeyboardEvent({
    required this.state,
    required this.key,
  });
}
