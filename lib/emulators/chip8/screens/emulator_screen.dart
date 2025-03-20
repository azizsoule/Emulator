import 'dart:async';

import 'package:emulator/core/utils/rom_loader.dart';
import 'package:flutter/material.dart';

import '../chip8.dart';
import '../widgets/chip8_display.dart';
import '../widgets/chip8_keyboard.dart';

class EmulatorScreen extends StatefulWidget {
  const EmulatorScreen({super.key});

  @override
  State<EmulatorScreen> createState() => _EmulatorScreenState();
}

class _EmulatorScreenState extends State<EmulatorScreen> {
  final Chip8 emulator = Chip8();
  Timer? _timer;
  bool isRunning = false;
  double displayScale = 10.0;
  Color pixelColor = Colors.green;
  Color backgroundColor = Colors.black;
  double emulationSpeed = 700.0; // Instructions per second
  bool gridEnabled = false;
  double gridOpacity = 0.3;

  @override
  void initState() {
    super.initState();
    emulator.initialize();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void startEmulation() {
    if (!isRunning) {
      final interval = (1000 / emulationSpeed).round();
      _timer = Timer.periodic(Duration(microseconds: interval), (timer) {
        emulator.emulateCycle();
        setState(() {});
      });
      setState(() {
        isRunning = true;
      });
    }
  }

  void stopEmulation() {
    _timer?.cancel();
    setState(() {
      isRunning = false;
    });
  }

  void loadROM(List<int> rom) {
    stopEmulation();
    emulator.initialize();
    emulator.loadROM(rom);
    startEmulation();
  }

  void _showSettings() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Row(
                children: [
                  const Text('Emulator Settings'),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.restore),
                    onPressed: () {
                      setState(() {
                        displayScale = 10.0;
                        pixelColor = Colors.green;
                        backgroundColor = Colors.black;
                        emulationSpeed = 700.0;
                        gridEnabled = false;
                        gridOpacity = 0.3;
                      });
                      this.setState(() {});
                    },
                    tooltip: 'Reset to defaults',
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSettingsSection(
                      'Display Scale',
                      Slider(
                        value: displayScale,
                        min: 5.0,
                        max: 20.0,
                        divisions: 15,
                        label: displayScale.round().toString(),
                        onChanged: (value) {
                          setState(() => displayScale = value);
                          this.setState(() {});
                        },
                      ),
                    ),
                    _buildSettingsSection(
                      'Emulation Speed',
                      Column(
                        children: [
                          Slider(
                            value: emulationSpeed,
                            min: 100.0,
                            max: 2000.0,
                            divisions: 19,
                            label: '${emulationSpeed.round()} Hz',
                            onChanged: (value) {
                              setState(() => emulationSpeed = value);
                              if (isRunning) {
                                stopEmulation();
                                startEmulation();
                              }
                            },
                          ),
                          Text(
                            '${emulationSpeed.round()} instructions per second',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    _buildSettingsSection(
                      'Pixel Color',
                      Wrap(
                        spacing: 8,
                        children: [
                          Colors.green,
                          Colors.amber,
                          Colors.blue,
                          Colors.red,
                          Colors.white,
                          Colors.purple,
                          Colors.cyan,
                          Colors.orange,
                        ].map((color) => _colorButton(color, setState)).toList(),
                      ),
                    ),
                    _buildSettingsSection(
                      'Background Color',
                      Wrap(
                        spacing: 8,
                        children: [
                          Colors.black,
                          Colors.grey[900]!,
                          Colors.grey[800]!,
                          Colors.blue[900]!,
                          Colors.green[900]!,
                        ]
                            .map((color) => _colorButton(
                                  color,
                                  setState,
                                  isBackground: true,
                                ))
                            .toList(),
                      ),
                    ),
                    _buildSettingsSection(
                      'Grid',
                      Column(
                        children: [
                          SwitchListTile(
                            title: const Text('Show Grid'),
                            value: gridEnabled,
                            onChanged: (value) {
                              setState(() => gridEnabled = value);
                              this.setState(() {});
                            },
                          ),
                          if (gridEnabled)
                            Slider(
                              value: gridOpacity,
                              min: 0.1,
                              max: 1.0,
                              divisions: 9,
                              label: 'Opacity: ${(gridOpacity * 100).round()}%',
                              onChanged: (value) {
                                setState(() => gridOpacity = value);
                                this.setState(() {});
                              },
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildSettingsSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        content,
      ],
    );
  }

  Widget _colorButton(Color color, StateSetter setState, {bool isBackground = false}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isBackground) {
            backgroundColor = color;
          } else {
            pixelColor = color;
          }
        });
        this.setState(() {});
      },
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: (isBackground ? backgroundColor : pixelColor) == color ? Colors.white : Colors.grey,
            width: (isBackground ? backgroundColor : pixelColor) == color ? 2 : 1,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('CHIP-8 Emulator'),
        actions: [
          IconButton(
            icon: Icon(isRunning ? Icons.pause : Icons.play_arrow),
            onPressed: isRunning ? stopEmulation : startEmulation,
          ),
          IconButton(
            icon: const Icon(Icons.folder_open),
            onPressed: () async {
              final rom = await RomLoader.loadROM();
              if (rom != null) {
                loadROM(rom);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettings,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: Chip8Display(
                  display: emulator.display,
                  scale: displayScale,
                  pixelColor: pixelColor,
                  showGrid: gridEnabled,
                  gridOpacity: gridOpacity,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Chip8Keyboard(
              onKeyPressed: (int key) => emulator.keypad[key] = true,
              onKeyReleased: (int key) => emulator.keypad[key] = false,
            ),
          ),
        ],
      ),
    );
  }
}
