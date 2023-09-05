import 'dart:typed_data';

class Chip8CPU {
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
