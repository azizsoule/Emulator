import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:emulator/core/emulators/base/emulator.dart';
import 'package:emulator/core/emulators/base/keyboard.dart';
import 'package:emulator/core/emulators/chip_8/screen.dart';
import 'package:flutter/material.dart';

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
            controller: StreamController<EmulatorKeyboardEvent>(),
          ),
        );

  @override
  void loadProgram(List<int> program) {
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
  void decode() {}

  @override
  void execute(int opcode) {
    final int addr = opcode & 0x0FFF;
    final int n = opcode & 0x000F;
    final int x = (opcode & 0x0F00) >> 8;
    final int y = (opcode & 0x00F0) >> 4;
    final int byte = opcode & 0x00FF;

    switch (opcode & 0xF000) {
      case 0x0000:
        switch (opcode) {
          case 0x00E0:
            // TODO : Clear screen
            break;
          case 0x00EE:
            cpu.pc = cpu.s.last;
            cpu.s.removeAt(cpu.s.length - 1);
            cpu.sp = cpu.sp - 1;
            break;
          default:
            cpu.pc = addr;
            break;
        }
        break;
      case 0x1000:
        cpu.pc = addr;
        break;
      case 0x2000:
        cpu.sp = cpu.sp + 1;
        cpu.s.add(cpu.pc);
        cpu.pc = addr;
        break;
      case 0x3000:
        if (cpu.v[x] == byte) {
          cpu.pc = cpu.pc + 2;
        }
        break;
      case 0x4000:
        if (cpu.v[x] != byte) {
          cpu.pc = cpu.pc + 2;
        }
        break;
      case 0x5000:
        if (cpu.v[x] == cpu.v[y]) {
          cpu.pc = cpu.pc + 2;
        }
        break;
      case 0x6000:
        cpu.v[x] = byte;
        break;
      case 0x7000:
        cpu.v[x] = cpu.v[x] + byte;
        break;
      case 0x8000:
        switch (n) {
          case 0x0:
            cpu.v[x] = cpu.v[y];
            break;
          case 0x1:
            cpu.v[x] = cpu.v[x] | cpu.v[y];
            break;
          case 0x2:
            cpu.v[x] = cpu.v[x] & cpu.v[y];
            break;
          case 0x3:
            cpu.v[x] = cpu.v[x] ^ cpu.v[y];
            break;
          case 0x4:
            final int additionResult = cpu.v[x] + cpu.v[y];
            cpu.v[0xF] = additionResult > 0xFF ? 0x1 : 0x0;
            cpu.v[x] = additionResult;
            break;
          case 0x5:
            cpu.v[0xF] = cpu.v[x] > cpu.v[y] ? 0x1 : 0x0;
            cpu.v[x] = cpu.v[x] - cpu.v[y];
            break;
          case 0x6:
            cpu.v[0xF] = cpu.v[x] & 0x1;
            cpu.v[x] = cpu.v[x] >> 1;
            break;
          case 0x7:
            cpu.v[0xF] = cpu.v[y] > cpu.v[x] ? 0x1 : 0x0;
            cpu.v[x] = cpu.v[y] - cpu.v[x];
            break;
          case 0xE:
            cpu.v[0xF] = cpu.v[x] & 0x80;
            cpu.v[x] = cpu.v[x] << 1;
            break;
        }
        break;
      case 0x9000:
        if (cpu.v[x] != cpu.v[y]) {
          cpu.pc = cpu.pc + 2;
        }
        break;
      case 0xA000:
        cpu.i = addr;
        break;
      case 0xB000:
        cpu.pc = addr + cpu.v[0];
        break;
      case 0xC000:
        cpu.v[x] = Random().nextInt(256) & byte;
        break;
      case 0xD000:
        // About display
        break;
      case 0xE000:
        // About keyboard
        break;
      case 0xF000:
        break;
      default:
        print("Unknow instruction");
        break;
    }
  }

  @override
  void onKeyPressed(EmulatorKey key) {
    // TODO: implement onKeyPressed
  }

  @override
  void onKeyReleased(EmulatorKey key) {
    // TODO: implement onKeyReleased
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
