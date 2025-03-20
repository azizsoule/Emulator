import 'dart:math' as math;

class Chip8Exception implements Exception {
  final String message;
  Chip8Exception(this.message);
  @override
  String toString() => 'Chip8Exception: $message';
}

class Chip8 {
  // System memory (4KB)
  final List<int> memory = List.filled(4096, 0);
  
  // CPU registers (V0-VF)
  final List<int> V = List.filled(16, 0);
  
  // Index register I
  int I = 0;
  
  // Program counter
  int pc = 0x200; // Programs typically start at 0x200 (512)
  
  // Stack for subroutines
  final List<int> stack = List.filled(16, 0);
  int sp = 0; // Stack pointer
  
  // Timers
  int delayTimer = 0;
  int soundTimer = 0;
  
  // Display buffer (64x32 pixels)
  final List<bool> display = List.filled(64 * 32, false);
  
  // Keypad (16 keys)
  final List<bool> keypad = List.filled(16, false);

  // Random number generator
  final _random = math.Random();
  
  // Font set (0-F)
  static const List<int> fontSet = [
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
    0xF0, 0x80, 0xF0, 0x80, 0x80  // F
  ];

  Chip8() {
    initialize();
  }

  void initialize() {
    // Clear memory
    memory.fillRange(0, memory.length, 0);
    
    // Load fontset into memory (0x000-0x080)
    for (int i = 0; i < fontSet.length; i++) {
      memory[i] = fontSet[i];
    }
    
    // Clear registers V0-VF
    V.fillRange(0, V.length, 0);
    
    // Clear display
    display.fillRange(0, display.length, false);
    
    // Clear stack
    stack.fillRange(0, stack.length, 0);
    
    // Clear keypad state
    keypad.fillRange(0, keypad.length, false);
    
    // Reset timers
    delayTimer = 0;
    soundTimer = 0;
    
    // Reset pointers
    I = 0;
    pc = 0x200;
    sp = 0;
  }

  void loadROM(List<int> rom) {
    if (rom.length > 4096 - 0x200) {
      throw Chip8Exception('ROM too large: ${rom.length} bytes (maximum: ${4096 - 0x200} bytes)');
    }
    
    for (int i = 0; i < rom.length; i++) {
      memory[0x200 + i] = rom[i];
    }
  }

  void emulateCycle() {
    // Fetch opcode (2 bytes)
    final opcode = (memory[pc] << 8) | memory[pc + 1];
    
    // Increment program counter before execution
    pc += 2;
    
    try {
      // Decode and execute opcode
      executeInstruction(opcode);
    } catch (e) {
      throw Chip8Exception('Error executing opcode 0x${opcode.toRadixString(16).padLeft(4, '0')}: $e');
    }
    
    // Update timers at 60Hz (handled externally by the timer)
    if (delayTimer > 0) delayTimer--;
    if (soundTimer > 0) soundTimer--;
  }

  void executeInstruction(int opcode) {
    // Extract common opcode components
    final x = (opcode & 0x0F00) >> 8;
    final y = (opcode & 0x00F0) >> 4;
    final n = opcode & 0x000F;
    final nn = opcode & 0x00FF;
    final nnn = opcode & 0x0FFF;

    switch (opcode & 0xF000) {
      case 0x0000:
        switch (opcode) {
          case 0x00E0: // Clear display
            display.fillRange(0, display.length, false);
            break;
          case 0x00EE: // Return from subroutine
            if (sp == 0) throw Chip8Exception('Stack underflow');
            sp--;
            pc = stack[sp];
            break;
          default:
            throw Chip8Exception('Unknown opcode: 0x${opcode.toRadixString(16)}');
        }
        break;

      case 0x1000: // 1NNN: Jump to address NNN
        pc = nnn;
        break;

      case 0x2000: // 2NNN: Call subroutine at NNN
        if (sp >= 16) throw Chip8Exception('Stack overflow');
        stack[sp] = pc;
        sp++;
        pc = nnn;
        break;

      case 0x3000: // 3XNN: Skip next instruction if VX equals NN
        if (V[x] == nn) pc += 2;
        break;

      case 0x4000: // 4XNN: Skip next instruction if VX doesn't equal NN
        if (V[x] != nn) pc += 2;
        break;

      case 0x5000: // 5XY0: Skip next instruction if VX equals VY
        if (V[x] == V[y]) pc += 2;
        break;

      case 0x6000: // 6XNN: Set VX to NN
        V[x] = nn;
        break;

      case 0x7000: // 7XNN: Add NN to VX
        V[x] = (V[x] + nn) & 0xFF;
        break;

      case 0x8000:
        switch (n) {
          case 0x0: // 8XY0: Set VX to VY
            V[x] = V[y];
            break;
          case 0x1: // 8XY1: Set VX to VX OR VY
            V[x] |= V[y];
            break;
          case 0x2: // 8XY2: Set VX to VX AND VY
            V[x] &= V[y];
            break;
          case 0x3: // 8XY3: Set VX to VX XOR VY
            V[x] ^= V[y];
            break;
          case 0x4: // 8XY4: Add VY to VX with carry
            final sum = V[x] + V[y];
            V[0xF] = sum > 0xFF ? 1 : 0;
            V[x] = sum & 0xFF;
            break;
          case 0x5: // 8XY5: Subtract VY from VX
            V[0xF] = V[x] >= V[y] ? 1 : 0;
            V[x] = (V[x] - V[y]) & 0xFF;
            break;
          case 0x6: // 8XY6: Shift VX right by 1
            V[0xF] = V[x] & 0x1;
            V[x] >>= 1;
            break;
          case 0x7: // 8XY7: Set VX to VY minus VX
            V[0xF] = V[y] >= V[x] ? 1 : 0;
            V[x] = (V[y] - V[x]) & 0xFF;
            break;
          case 0xE: // 8XYE: Shift VX left by 1
            V[0xF] = (V[x] & 0x80) >> 7;
            V[x] = (V[x] << 1) & 0xFF;
            break;
          default:
            throw Chip8Exception('Unknown opcode: 0x${opcode.toRadixString(16)}');
        }
        break;

      case 0x9000: // 9XY0: Skip next instruction if VX doesn't equal VY
        if (V[x] != V[y]) pc += 2;
        break;

      case 0xA000: // ANNN: Set I to NNN
        I = nnn;
        break;

      case 0xB000: // BNNN: Jump to address NNN plus V0
        pc = nnn + V[0];
        break;

      case 0xC000: // CXNN: Set VX to random number AND NN
        V[x] = _random.nextInt(256) & nn;
        break;

      case 0xD000: // DXYN: Draw sprite at (VX, VY) with height N
        V[0xF] = 0;
        for (int row = 0; row < n; row++) {
          final spriteByte = memory[I + row];
          for (int col = 0; col < 8; col++) {
            if ((spriteByte & (0x80 >> col)) != 0) {
              final xCoord = (V[x] + col) % 64;
              final yCoord = (V[y] + row) % 32;
              final index = yCoord * 64 + xCoord;
              
              if (display[index]) V[0xF] = 1;
              display[index] = !display[index];
            }
          }
        }
        break;

      case 0xE000:
        switch (nn) {
          case 0x9E: // EX9E: Skip next instruction if key VX is pressed
            if (keypad[V[x]]) pc += 2;
            break;
          case 0xA1: // EXA1: Skip next instruction if key VX isn't pressed
            if (!keypad[V[x]]) pc += 2;
            break;
          default:
            throw Chip8Exception('Unknown opcode: 0x${opcode.toRadixString(16)}');
        }
        break;

      case 0xF000:
        switch (nn) {
          case 0x07: // FX07: Set VX to delay timer value
            V[x] = delayTimer;
            break;
          case 0x0A: // FX0A: Wait for key press, store in VX
            bool keyPressed = false;
            for (int i = 0; i < keypad.length; i++) {
              if (keypad[i]) {
                V[x] = i;
                keyPressed = true;
                break;
              }
            }
            if (!keyPressed) pc -= 2;
            break;
          case 0x15: // FX15: Set delay timer to VX
            delayTimer = V[x];
            break;
          case 0x18: // FX18: Set sound timer to VX
            soundTimer = V[x];
            break;
          case 0x1E: // FX1E: Add VX to I
            I += V[x];
            break;
          case 0x29: // FX29: Set I to location of sprite for digit VX
            I = V[x] * 5;
            break;
          case 0x33: // FX33: Store BCD representation of VX
            memory[I] = V[x] ~/ 100;
            memory[I + 1] = (V[x] % 100) ~/ 10;
            memory[I + 2] = V[x] % 10;
            break;
          case 0x55: // FX55: Store V0 to VX in memory starting at I
            for (int i = 0; i <= x; i++) {
              memory[I + i] = V[i];
            }
            break;
          case 0x65: // FX65: Fill V0 to VX with memory starting at I
            for (int i = 0; i <= x; i++) {
              V[i] = memory[I + i];
            }
            break;
          default:
            throw Chip8Exception('Unknown opcode: 0x${opcode.toRadixString(16)}');
        }
        break;

      default:
        throw Chip8Exception('Unknown opcode: 0x${opcode.toRadixString(16)}');
    }
  }

  // Debug methods
  String dumpRegisters() {
    final buffer = StringBuffer();
    buffer.writeln('Registers:');
    for (int i = 0; i < V.length; i++) {
      buffer.writeln('V${i.toRadixString(16).toUpperCase()}: 0x${V[i].toRadixString(16).padLeft(2, '0')}');
    }
    buffer.writeln('I: 0x${I.toRadixString(16).padLeft(4, '0')}');
    buffer.writeln('PC: 0x${pc.toRadixString(16).padLeft(4, '0')}');
    buffer.writeln('SP: 0x${sp.toRadixString(16)}');
    return buffer.toString();
  }

  String dumpMemory([int start = 0, int length = 16]) {
    final buffer = StringBuffer();
    buffer.writeln('Memory dump:');
    for (int i = start; i < start + length && i < memory.length; i++) {
      if (i % 16 == 0) {
        buffer.write('\n${i.toRadixString(16).padLeft(4, '0')}: ');
      }
      buffer.write('${memory[i].toRadixString(16).padLeft(2, '0')} ');
    }
    return buffer.toString();
  }
} 