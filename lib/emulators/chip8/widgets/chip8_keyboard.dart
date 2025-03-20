import 'package:flutter/material.dart';

class Chip8Keyboard extends StatelessWidget {
  final Function(int) onKeyPressed;
  final Function(int) onKeyReleased;

  const Chip8Keyboard({
    super.key,
    required this.onKeyPressed,
    required this.onKeyReleased,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: GridView.count(
        crossAxisCount: 4,
        childAspectRatio: 1.5,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        children: [
          // CHIP-8 keyboard layout:
          // 1 2 3 C
          // 4 5 6 D
          // 7 8 9 E
          // A 0 B F
          for (int i = 0; i < 16; i++)
            _buildKey(getKeyLabel(i), i),
        ],
      ),
    );
  }

  String getKeyLabel(int index) {
    const List<String> labels = [
      '1', '2', '3', 'C',
      '4', '5', '6', 'D',
      '7', '8', '9', 'E',
      'A', '0', 'B', 'F'
    ];
    return labels[index];
  }

  Widget _buildKey(String label, int keyCode) {
    return GestureDetector(
      onTapDown: (_) => onKeyPressed(keyCode),
      onTapUp: (_) => onKeyReleased(keyCode),
      onTapCancel: () => onKeyReleased(keyCode),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[600]!),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
} 