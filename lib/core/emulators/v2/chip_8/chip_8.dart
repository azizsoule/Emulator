import 'dart:math';
import 'dart:typed_data';

import 'package:emulator/core/emulators/v1/base/emulator.dart';
import 'package:emulator/core/emulators/v1/chip_8/screen.dart';
import 'package:emulator/core/utils/debug_print.dart';
import 'package:emulator/core/utils/wrapper.dart';
import 'package:flutter/material.dart';

import 'cpu.dart';
import 'keyboard.dart';

class Chip8Emulator extends Emulator<Chip8CPU, Uint8List, Chip8Screen, Chip8KeyBoard> {
  Chip8Emulator({
    super.key,
  }) : super(
          cpu: Chip8CPU(),
          memory: Uint8List(4096),
          screen: Chip8Screen(scale: 5),
          keyboard: Chip8KeyBoard(),
        );

  static final Wrapper<Chip8Instruction> currentInstruction = Wrapper();

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
      memory[cpu.pc + i] = program[i];
    }
  }

  @override
  int fetch() {
    final int opcode = (memory[cpu.pc] << 8) | memory[cpu.pc + 1];
    cpu.pc = cpu.pc + 2;
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

    currentInstruction.content = object;

    switch (object.opcode & 0xF000) {
      case 0x0000:
        switch (object.opcode) {
          case 0x00E0:
            screen.clear();
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
        cpu.s.add(cpu.pc);
        cpu.sp = cpu.sp + 1;
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
            final additionResult = cpu.v[object.x] + cpu.v[object.y];
            cpu.v[object.x] = additionResult & 0xFF;
            cpu.v[0xF] = additionResult > 0xFF ? 1 : 0;
            break;
          case 0x5:
            final subsTractionResult = cpu.v[object.x] - cpu.v[object.y];
            cpu.v[object.x] = subsTractionResult & 0xFF;
            cpu.v[0xF] = subsTractionResult >= 0 ? 1 : 0;
            break;
          case 0x6:
            final vxLastBit = cpu.v[object.x] & 0x1;
            cpu.v[object.x] = cpu.v[object.x] >> 1;
            cpu.v[0xF] = vxLastBit;
            break;
          case 0x7:
            final subsTractionResult = cpu.v[object.y] - cpu.v[object.x];
            cpu.v[object.x] = subsTractionResult & 0xFF;
            cpu.v[0xF] = subsTractionResult >= 0 ? 1 : 0;
            break;
          case 0xE:
            final vxFirstBit = (cpu.v[object.x] & 0x80) >> 7;
            cpu.v[object.x] = (cpu.v[object.x] << 1) & 0xFF;
            cpu.v[0xF] = vxFirstBit;
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
        for (int j = 0; j < object.n; j++) {
          int byte = memory[cpu.i + j];

          for (int i = 0; i < 8; i++) {
            if ((byte & 0x80) > 0) {
              int x = cpu.v[object.x] + i;
              int y = cpu.v[object.y] + j;

              cpu.v[0xF] = screen.updatePixel(x, y) ? 1 : 0;
            }

            byte = byte << 1;
          }
        }
        break;
      case 0xE000:
        switch (object.byte) {
          case 0x9E:
            if (keyboard.pressedKey.content?.code == cpu.v[object.x]) {
              cpu.pc = cpu.pc + 2;
            }
            break;
          case 0xA1:
            if (keyboard.releasedKey.content?.code == cpu.v[object.x]) {
              cpu.pc = cpu.pc + 2;
            }
            break;
        }
        break;
      case 0xF000:
        switch (object.byte) {
          case 0x07:
            cpu.v[object.x] = cpu.dt;
            break;
          case 0x0A:
            while (keyboard.pressedKey.content == null) {}
            cpu.v[object.x] = keyboard.pressedKey.content?.code ?? cpu.v[object.x];
            break;
          case 0x15:
            cpu.dt = cpu.v[object.x];
            break;
          case 0x18:
            cpu.st = cpu.v[object.x];
            break;
          case 0x1E:
            cpu.i = cpu.i + cpu.v[object.x];
            break;
          case 0x29:
            cpu.i = cpu.v[object.x] * 5;
            break;
          case 0x33:
            memory[cpu.i] = cpu.v[object.x] ~/ 100;
            memory[cpu.i + 1] = (cpu.v[object.x] % 100) ~/ 10;
            memory[cpu.i + 2] = cpu.v[object.x] % 10;
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

    cpu.updateTimers();
  }

  @override
  void reset() {
    cpu.pc = 0x200;
    cpu.sp = 0;
    cpu.s.clear();
    cpu.v.fillRange(0, cpu.v.length, 0);
    cpu.i = 0;
    cpu.dt = 0;
    cpu.st = 0;
    screen.clear();
    memory.fillRange(0, memory.length, 0);
  }

  @override
  void onKeyPressed(key) {
    key as Chip8Key;
    if (currentInstruction.isNotEmpty) {
      cpu.v[currentInstruction.content!.x] = key.code;
    }
  }

  @override
  void onKeyReleased(key) {
    key as Chip8Key;
    if (currentInstruction.isNotEmpty) {
      cpu.v[currentInstruction.content!.x] = key.code;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("CHIP 8"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          screen,
          const SizedBox(
            height: 16,
          ),
          keyboard,
          const SizedBox(
            height: 16,
          ),
          TextButton(
            onPressed: pickFile,
            child: const Text("Charger une ROM"),
          ),
        ],
      ),
    );
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
