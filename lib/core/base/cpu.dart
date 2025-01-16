import 'package:comms/comms.dart' as comms;
import 'package:emulator/core/base/messages/cpu_input_messages.dart';
import 'package:emulator/core/base/messages/cpu_output_messages.dart';
import 'package:flutter/cupertino.dart';

enum CPUState {
  running,
  paused,
  stopped;

  bool get isRunning => this == CPUState.running;
  bool get isPaused => this == CPUState.paused;
  bool get isStopped => this == CPUState.stopped;
}

/// Emulator CPU representation
abstract class EmulatorCPU<Instruction, Memory> with comms.Sender<CPUOutputMessage>, comms.Listener<CPUInputMessage> {
  @protected
  final Memory memory;

  @protected
  CPUState _state;

  EmulatorCPU({
    required this.memory,
  }) : _state = CPUState.running {
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
    if (_state.isPaused) return;
    final instruction = fetch();
    execute(instruction);
    Future.delayed(
      Duration(milliseconds: 1000 ~/ cyclesPerSecond),
      cycle,
    );
  }

  void run() {
    _state = CPUState.running;
  }

  void pause() {
    _state = CPUState.paused;
  }

  @override
  void onMessage(CPUInputMessage message) {}
}
