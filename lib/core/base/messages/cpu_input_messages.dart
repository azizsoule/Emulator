/// Message receive from other components like keyboard, gamepad, ...
abstract class CPUInputMessage {}

/// Keyboard message
enum KeyState {
  pressed,
  released;

  bool get isPressed => this == KeyState.pressed;
  bool get isReleased => this == KeyState.released;
}

class KeyboardMessage<KEY> extends CPUInputMessage {
  final KeyState state;
  final KEY key;

  KeyboardMessage({
    required this.key,
    required this.state,
  });
}
