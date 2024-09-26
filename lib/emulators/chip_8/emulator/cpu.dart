import 'dart:math';
import 'dart:typed_data';

import 'package:emulator/core/base/cpu.dart';
import 'package:emulator/core/base/messages/cpu_input_messages.dart';
import 'package:emulator/core/base/messages/cpu_output_messages.dart';
import 'package:emulator/core/utils/debug_print.dart';
import 'package:emulator/emulators/chip_8/emulator/messages/cpu_output_messsages.dart';
import 'package:emulator/emulators/chip_8/emulator/shared_memory.dart';
import 'package:flutter/cupertino.dart';

class Chip8Instruction {
  final int addr;
  final int n;
  final int x;
  final int y;
  final int byte;
  final int opcode;

  Chip8Instruction({
    required this.addr,
    required this.n,
    required this.x,
    required this.y,
    required this.byte,
    required this.opcode,
  });
}

class Chip8CPU extends EmulatorCPU<Chip8Instruction, Uint8List> {
  // 16 8-bit registers
  final Uint8List _v = Uint8List(16);

  // 16-bit register
  int _i = 0;

  // 8-bit register
  // when this register is not 0, it is automatically decremented at a rate of 60Hz
  int _dt = 0;

  // 8-bit register
  // when this register is not 0, it is automatically decremented at a rate of 60Hz
  int _st = 0;

  // 16-bit program counter
  int _pc = 0x200;

  // 8-bit stack pointer
  int _sp = 0;

  // 16 16-bit values
  final List<int> _s = List<int>.empty(growable: true);

  Chip8CPU({
    required super.memory,
  });

  @protected
  void updateTimers() {
    if (_dt > 0) {
      _dt = _dt - 1;
    }

    if (_st > 0) {
      _st = _st - 1;
    }
  }

  @override
  int get cyclesPerSecond => 39;

  @override
  void loadProgram(List<int> program) {
    // Load sprites
    final List<int> sprites = [
      0xF0, 0x90, 0x90, 0x90, 0xF0, // 0
      0x20, 0x60, 0x20, 0x20, 0x70, // 1
      0xF0, 0x10, 0xF0, 0x80, 0xF0, // 2
      0xF0, 0x10, 0xF0, 0x10, 0xF0, // 3
      0x90, 0x90, 0xF0, 0x10, 0x10, // 4
      0xF0, 0x80, 0xF0, 0x10, 0xF0, // 5
      0xF0, 0x80, 0xF0, 0x90, 0xF0, // 6
      0xF0, 0x10, 0x20, 0x40, 0x40, // 7
      0xF0, 0x90, 0xF0, 0x90, 0xF0, // 8
      0xF0, 0x90, 0xF0, 0x10, 0xF0, // 9
      0xF0, 0x90, 0xF0, 0x90, 0x90, // A
      0xE0, 0x90, 0xE0, 0x90, 0xE0, // B
      0xF0, 0x80, 0x80, 0x80, 0xF0, // C
      0xE0, 0x90, 0x90, 0x90, 0xE0, // D
      0xF0, 0x80, 0xF0, 0x80, 0xF0, // E
      0xF0, 0x80, 0xF0, 0x80, 0x80, // F
    ];

    memory.fillRange(0, memory.length, 0);

    for (int i = 0; i < sprites.length; i++) {
      memory[i] = sprites[i];
    }

    // Load program
    for (var i = 0; i < program.length; i++) {
      memory[_pc + i] = program[i];
    }
  }

  @override
  void reset() {
    _pc = 0x200;
    _sp = 0;
    _s.clear();
    _v.fillRange(0, _v.length, 0);
    _i = 0;
    _dt = 0;
    _st = 0;
    send(const ClearScreenMessage());
    memory.fillRange(0, memory.length, 0);
    Chip8SharedMemory.reset();
  }

  @override
  Chip8Instruction fetch() {
    final int opcode = (memory[_pc] << 8) | memory[_pc + 1];
    _pc = _pc + 2;

    final int addr = opcode & 0x0FFF;
    final int n = opcode & 0x000F;
    final int x = (opcode & 0x0F00) >> 8;
    final int y = (opcode & 0x00F0) >> 4;
    final int byte = opcode & 0x00FF;

    return Chip8Instruction(
      addr: addr,
      n: n,
      x: x,
      y: y,
      byte: byte,
      opcode: opcode,
    );
  }

  @override
  void execute(Chip8Instruction instruction) {
    switch (instruction.opcode & 0xF000) {
      case 0x0000:
        switch (instruction.opcode) {
          case 0x00E0:
            send(const ClearScreenMessage());
            break;
          case 0x00EE:
            _pc = _s.last;
            _s.removeAt(_s.length - 1);
            _sp = _sp - 1;
            break;
          default:
            _pc = instruction.addr;
            break;
        }
        break;
      case 0x1000:
        _pc = instruction.addr;
        break;
      case 0x2000:
        _s.add(_pc);
        _sp = _sp + 1;
        _pc = instruction.addr;
        break;
      case 0x3000:
        if (_v[instruction.x] == instruction.byte) {
          _pc = _pc + 2;
        }
        break;
      case 0x4000:
        if (_v[instruction.x] != instruction.byte) {
          _pc = _pc + 2;
        }
        break;
      case 0x5000:
        if (_v[instruction.x] == _v[instruction.y]) {
          _pc = _pc + 2;
        }
        break;
      case 0x6000:
        _v[instruction.x] = instruction.byte;
        break;
      case 0x7000:
        _v[instruction.x] = _v[instruction.x] + instruction.byte;
        break;
      case 0x8000:
        switch (instruction.n) {
          case 0x0:
            _v[instruction.x] = _v[instruction.y];
            break;
          case 0x1:
            _v[instruction.x] = _v[instruction.x] | _v[instruction.y];
            break;
          case 0x2:
            _v[instruction.x] = _v[instruction.x] & _v[instruction.y];
            break;
          case 0x3:
            _v[instruction.x] = _v[instruction.x] ^ _v[instruction.y];
            break;
          case 0x4:
            final additionResult = _v[instruction.x] + _v[instruction.y];
            _v[instruction.x] = additionResult & 0xFF;
            _v[0xF] = additionResult > 0xFF ? 1 : 0;
            break;
          case 0x5:
            final subsTractionResult = _v[instruction.x] - _v[instruction.y];
            _v[instruction.x] = subsTractionResult & 0xFF;
            _v[0xF] = subsTractionResult >= 0 ? 1 : 0;
            break;
          case 0x6:
            final vxLastBit = _v[instruction.x] & 0x1;
            _v[instruction.x] = _v[instruction.x] >> 1;
            _v[0xF] = vxLastBit;
            break;
          case 0x7:
            final subsTractionResult = _v[instruction.y] - _v[instruction.x];
            _v[instruction.x] = subsTractionResult & 0xFF;
            _v[0xF] = subsTractionResult >= 0 ? 1 : 0;
            break;
          case 0xE:
            final vxFirstBit = (_v[instruction.x] & 0x80) >> 7;
            _v[instruction.x] = (_v[instruction.x] << 1) & 0xFF;
            _v[0xF] = vxFirstBit;
            break;
        }
        break;
      case 0x9000:
        if (_v[instruction.x] != _v[instruction.y]) {
          _pc = _pc + 2;
        }
        break;
      case 0xA000:
        _i = instruction.addr;
        break;
      case 0xB000:
        _pc = instruction.addr + _v[0];
        break;
      case 0xC000:
        _v[instruction.x] = Random().nextInt(256) & instruction.byte;
        break;
      case 0xD000:
        for (int j = 0; j < instruction.n; j++) {
          int byte = memory[_i + j];

          for (int i = 0; i < 8; i++) {
            if ((byte & 0x80) > 0) {
              int x = _v[instruction.x] + i;
              int y = _v[instruction.y] + j;

              send(UpdatePixelMessage(x: x, y: y));

              _v[0xF] = Chip8SharedMemory.updatePixelResponse == true ? 1 : 0;
            }

            byte = byte << 1;
          }
        }
        break;
      case 0xE000:
        switch (instruction.byte) {
          case 0x9E:
            if (Chip8SharedMemory.pressedKey?.code == _v[instruction.x]) {
              _pc = _pc + 2;
            }
            break;
          case 0xA1:
            if (Chip8SharedMemory.releasedKey?.code == _v[instruction.x]) {
              _pc = _pc + 2;
            }
            break;
        }
        break;
      case 0xF000:
        switch (instruction.byte) {
          case 0x07:
            _v[instruction.x] = _dt;
            break;
          case 0x0A:
            while (Chip8SharedMemory.pressedKey == null) {}
            _v[instruction.x] = Chip8SharedMemory.pressedKey?.code ?? _v[instruction.x];
            break;
          case 0x15:
            _dt = _v[instruction.x];
            break;
          case 0x18:
            _st = _v[instruction.x];
            break;
          case 0x1E:
            _i = _i + _v[instruction.x];
            break;
          case 0x29:
            _i = _v[instruction.x] * 5;
            break;
          case 0x33:
            memory[_i] = _v[instruction.x] ~/ 100;
            memory[_i + 1] = (_v[instruction.x] % 100) ~/ 10;
            memory[_i + 2] = _v[instruction.x] % 10;
            break;
          case 0x55:
            for (int i = 0; i <= instruction.x; i++) {
              memory[i + i] = _v[i];
            }
            break;
          case 0x65:
            for (int i = 0; i <= instruction.x; i++) {
              _v[i] = memory[i + i];
            }
            break;
        }
        break;
      default:
        printDebug("Unknown instruction");
        break;
    }

    updateTimers();
  }

  @override
  void onMessage(CPUInputMessage message) {
    switch (message) {
      case KeyboardMessage keyboardMessage:
        _handleKeyboardMessage(keyboardMessage);
      default:
        printDebug("Unknown message");
    }
  }

  void _handleKeyboardMessage(KeyboardMessage keyboardMessage) {}
}
