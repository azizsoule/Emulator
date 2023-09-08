import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:emulator/core/emulators/base/emulator.dart';
import 'package:emulator/core/emulators/base/keyboard.dart';
import 'package:emulator/core/emulators/chip_8/screen.dart';
import 'package:flutter/material.dart';

import '../../utils/debug_print.dart';
import 'cpu.dart';
import 'keyboard.dart';

class Chip8Emulator extends Emulator<Chip8CPU, Uint8List, Chip8Screen, Chip8KeyBoard> {
  Chip8Emulator({
    super.key,
  }) : super(
          cpu: Chip8CPU(),
          memory: Uint8List(4096),
          screen: const Chip8Screen(),
          keyboard: Chip8KeyBoard(
            controller: StreamController<EmulatorKeyboardEvent<Chip8Key>>(),
          ),
        );

  void _loadSprites() {}

  @override
  void loadProgram(List<int> program) {
    _loadSprites();
    for (var i = 0; i < program.length; i++) {
      memory[cpu.pc + i] = program[i];
    }
  }

  @override
  int fetch() {
    final int opcode = (memory[cpu.pc] << 8) | memory[cpu.pc + 1];
    return opcode;
  }

  @override
  Chip8Instruction decode(int opcode) {
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
  void execute(Object object) {
    object as Chip8Instruction;

    switch (object.opcode & 0xF000) {
      case 0x0000:
        switch (object.opcode) {
          case 0x00E0:
            // TODO : Clear screen
            break;
          case 0x00EE:
            cpu.pc = cpu.s.last;
            cpu.s.removeAt(cpu.s.length - 1);
            cpu.sp = cpu.sp - 1;
            break;
          default:
            cpu.pc = object.addr;
            break;
        }
        break;
      case 0x1000:
        cpu.pc = object.addr;
        break;
      case 0x2000:
        cpu.sp = cpu.sp + 1;
        cpu.s.add(cpu.pc);
        cpu.pc = object.addr;
        break;
      case 0x3000:
        if (cpu.v[object.x] == object.byte) {
          cpu.pc = cpu.pc + 2;
        }
        break;
      case 0x4000:
        if (cpu.v[object.x] != object.byte) {
          cpu.pc = cpu.pc + 2;
        }
        break;
      case 0x5000:
        if (cpu.v[object.x] == cpu.v[object.y]) {
          cpu.pc = cpu.pc + 2;
        }
        break;
      case 0x6000:
        cpu.v[object.x] = object.byte;
        break;
      case 0x7000:
        cpu.v[object.x] = cpu.v[object.x] + object.byte;
        break;
      case 0x8000:
        switch (object.n) {
          case 0x0:
            cpu.v[object.x] = cpu.v[object.y];
            break;
          case 0x1:
            cpu.v[object.x] = cpu.v[object.x] | cpu.v[object.y];
            break;
          case 0x2:
            cpu.v[object.x] = cpu.v[object.x] & cpu.v[object.y];
            break;
          case 0x3:
            cpu.v[object.x] = cpu.v[object.x] ^ cpu.v[object.y];
            break;
          case 0x4:
            final int additionResult = cpu.v[object.x] + cpu.v[object.y];
            cpu.v[0xF] = additionResult > 0xFF ? 0x1 : 0x0;
            cpu.v[object.x] = additionResult;
            break;
          case 0x5:
            cpu.v[0xF] = cpu.v[object.x] > cpu.v[object.y] ? 0x1 : 0x0;
            cpu.v[object.x] = cpu.v[object.x] - cpu.v[object.y];
            break;
          case 0x6:
            cpu.v[0xF] = cpu.v[object.x] & 0x1;
            cpu.v[object.x] = cpu.v[object.x] >> 1;
            break;
          case 0x7:
            cpu.v[0xF] = cpu.v[object.y] > cpu.v[object.x] ? 0x1 : 0x0;
            cpu.v[object.x] = cpu.v[object.y] - cpu.v[object.x];
            break;
          case 0xE:
            cpu.v[0xF] = cpu.v[object.x] & 0x80;
            cpu.v[object.x] = cpu.v[object.x] << 1;
            break;
        }
        break;
      case 0x9000:
        if (cpu.v[object.x] != cpu.v[object.y]) {
          cpu.pc = cpu.pc + 2;
        }
        break;
      case 0xA000:
        cpu.i = object.addr;
        break;
      case 0xB000:
        cpu.pc = object.addr + cpu.v[0];
        break;
      case 0xC000:
        cpu.v[object.x] = Random().nextInt(256) & object.byte;
        break;
      case 0xD000:
        // About display
        break;
      case 0xE000:
        switch (object.n) {
          case 0xE:
            if (keyboard.pressedKey.data?.code == cpu.v[object.x]) {
              cpu.pc = cpu.pc + 2;
            }
            break;
          case 0x1:
            if (keyboard.releasedKey.data?.code == cpu.v[object.x]) {
              cpu.pc = cpu.pc + 2;
            }
            break;
        }
        break;
      case 0xF000:
        switch (object.byte) {
          case 0x07:
            cpu.v[object.x] = cpu.delay;
            break;
          case 0x0A:
            while (keyboard.pressedKey.data == null) {}
            cpu.v[object.x] = keyboard.pressedKey.data?.code ?? cpu.v[object.x];
            break;
          case 0x15:
            cpu.delay = cpu.v[object.x];
            break;
          case 0x18:
            cpu.sound = cpu.v[object.x];
            break;
          case 0x1E:
            cpu.i = cpu.i + cpu.v[object.x];
            break;
          case 0x29:
            // Sprite
            break;
          case 0x33:
            // Dont got it
            break;
          case 0x55:
            for (int i = 0; i <= object.x; i++) {
              memory[cpu.i + i] = cpu.v[i];
            }
            break;
          case 0x65:
            for (int i = 0; i <= object.x; i++) {
              cpu.v[i] = memory[i + cpu.i];
            }
            break;
        }
        break;
      default:
        printDebug("Unknown instruction");
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}

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
