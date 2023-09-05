import 'dart:math';
import 'dart:typed_data';

class CPU<M, R> {
  final M memory;
  final R registers;

  CPU(this.memory, this.registers);
}

class Chip8Register {
  // 16 8-bit registers
  final Uint8List v = Uint8List(16);

  // 16-bit register
  int i = 0;

  // 8-bit register
  int delay = 0;

  // 8-bit register
  // when this register is not 0, it is automatically decremented at a rate of 60Hz
  int sound = 0;

  // 16-bit program counter
  // when this register is not 0, it is automatically decremented at a rate of 60Hz
  int pc = 0x200;

  // 8-bit stack pointer
  int sp = 0;

  // 16 16-bit values
  final List<int> s = List<int>.empty(growable: true);
}

class Chip8 extends CPU<Uint8List, Chip8Register> {
  Chip8() : super(Uint8List(4096), Chip8Register());

  void loadProgram(List<int> program) {
    for (var i = 0; i < program.length; i++) {
      memory[registers.pc + i] = program[i];
    }
  }

  int fetch() {
    final int opcode = (memory[registers.pc] << 8) | memory[registers.pc + 1];
    return opcode;
  }

  void decode() {}

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
            registers.pc = registers.s.last;
            registers.s.removeAt(registers.s.length - 1);
            registers.sp = registers.sp - 1;
            break;
          default:
            registers.pc = addr;
            break;
        }
        break;
      case 0x1000:
        registers.pc = addr;
        break;
      case 0x2000:
        registers.sp = registers.sp + 1;
        registers.s.add(registers.pc);
        registers.pc = addr;
        break;
      case 0x3000:
        if (registers.v[x] == byte) {
          registers.pc = registers.pc + 2;
        }
        break;
      case 0x4000:
        if (registers.v[x] != byte) {
          registers.pc = registers.pc + 2;
        }
        break;
      case 0x5000:
        if (registers.v[x] == registers.v[y]) {
          registers.pc = registers.pc + 2;
        }
        break;
      case 0x6000:
        registers.v[x] = byte;
        break;
      case 0x7000:
        registers.v[x] = registers.v[x] + byte;
        break;
      case 0x8000:
        switch (n) {
          case 0x0:
            registers.v[x] = registers.v[y];
            break;
          case 0x1:
            registers.v[x] = registers.v[x] | registers.v[y];
            break;
          case 0x2:
            registers.v[x] = registers.v[x] & registers.v[y];
            break;
          case 0x3:
            registers.v[x] = registers.v[x] ^ registers.v[y];
            break;
          case 0x4:
            final int additionResult = registers.v[x] + registers.v[y];
            registers.v[0xF] = additionResult > 0xFF ? 0x1 : 0x0;
            registers.v[x] = additionResult;
            break;
          case 0x5:
            registers.v[0xF] = registers.v[x] > registers.v[y] ? 0x1 : 0x0;
            registers.v[x] = registers.v[x] - registers.v[y];
            break;
          case 0x6:
            registers.v[0xF] = registers.v[x] & 0x1;
            registers.v[x] = registers.v[x] >> 1;
            break;
          case 0x7:
            registers.v[0xF] = registers.v[y] > registers.v[x] ? 0x1 : 0x0;
            registers.v[x] = registers.v[y] - registers.v[x];
            break;
          case 0xE:
            registers.v[0xF] = registers.v[x] & 0x80;
            registers.v[x] = registers.v[x] << 1;
            break;
        }
        break;
      case 0x9000:
        if (registers.v[x] != registers.v[y]) {
          registers.pc = registers.pc + 2;
        }
        break;
      case 0xA000:
        registers.i = addr;
        break;
      case 0xB000:
        registers.pc = addr + registers.v[0];
        break;
      case 0xC000:
        registers.v[x] = Random().nextInt(256) & byte;
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
}
