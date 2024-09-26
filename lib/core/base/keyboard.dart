import 'package:comms/comms.dart';
import 'package:emulator/core/base/messages/cpu_input_messages.dart';
import 'package:flutter/cupertino.dart';

abstract class EmulatorKeyboard<KEY> extends StatelessWidget with Sender<CPUInputMessage> {
  EmulatorKeyboard({
    super.key,
  });

  @protected
  List<KEY> get keys;

  @protected
  void onKeyDown(KEY key) {
    send(KeyboardMessage<KEY>(
      key: key,
      state: KeyState.pressed,
    ));
  }

  @protected
  void onKeyUp(KEY key) {
    send(KeyboardMessage<KEY>(
      key: key,
      state: KeyState.released,
    ));
  }
}
