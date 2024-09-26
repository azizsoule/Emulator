import 'package:emulator/core/base/messages/cpu_output_messages.dart';

class UpdatePixelMessage extends CPUOutputMessage {
  final int x;
  final int y;

  const UpdatePixelMessage({
    required this.x,
    required this.y,
  });
}
