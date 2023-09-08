import 'dart:async';

import 'package:flutter/cupertino.dart';

abstract class EmulatorKeyboard extends StatelessWidget {
  final StreamController<EmulatorKeyboardEvent> controller;

  const EmulatorKeyboard({
    super.key,
    required this.controller,
  });

  List<EmulatorKey> get keys;

  void onKeyDown(EmulatorKey key) {
    controller.add(
      EmulatorKeyboardEvent(
        state: EmulatorKeyState.pressed,
        key: key,
      ),
    );
  }

  void onKeyUp(EmulatorKey key) {
    controller.add(
      EmulatorKeyboardEvent(
        state: EmulatorKeyState.released,
        key: key,
      ),
    );
  }
}

abstract class EmulatorKey<A, B> {
  final A key;
  final B value;

  EmulatorKey({
    required this.key,
    required this.value,
  });
}

enum EmulatorKeyState {
  pressed,
  released;

  bool get isPressed => this == EmulatorKeyState.pressed;

  bool get isReleased => this == EmulatorKeyState.released;
}

class EmulatorKeyboardEvent {
  final EmulatorKeyState state;
  final EmulatorKey key;

  EmulatorKeyboardEvent({
    required this.state,
    required this.key,
  });
}
