import 'package:flutter/material.dart';

import 'app/chip8/pages/chip8_page.dart';
import 'core/widgets/emulator_item_widget.dart';

void main() {
  runApp(const EmulatorApp());
}

class EmulatorApp extends StatelessWidget {
  const EmulatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Emulator',
      home: MainPage(),
    );
  }
}

class MainPage extends StatelessWidget {
  const MainPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Emulators"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            EmulatorItemWidget(
              image: "assets/images/chip_8.png",
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const Chip8Page(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
