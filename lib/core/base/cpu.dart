import 'package:comms/comms.dart' as comms;
import 'package:emulator/core/base/messages/cpu_input_messages.dart';
import 'package:emulator/core/base/messages/cpu_output_messages.dart';
import 'package:flutter/cupertino.dart';

/// Emulator CPU representation
abstract class EmulatorCPU<Instruction, Memory> with comms.Sender<CPUOutputMessage>, comms.Listener<CPUInputMessage> {
  @protected
  final Memory memory;

  EmulatorCPU({
    required this.memory,
  }) {
    listen();
  }

  /// Implements how the CPU should fetch instructions from the memory
  @protected
  Instruction fetch();

  /// Implements execution of an instruction
  @protected
  void execute(Instruction instruction);

  /// Reset the CPU to its initial state
  void reset();

  /// How many CPU cycles per second
  @protected
  int get cyclesPerSecond;

  /// How the CPU load a program into memory
  void loadProgram(List<int> program);

  /// One CPU cycle
  void cycle() {
    final instruction = fetch();
    execute(instruction);
    Future.delayed(
      Duration(milliseconds: 1000 ~/ cyclesPerSecond),
      cycle,
    );
  }

  void pause() {}
}
