import 'package:comms/comms.dart' as comms;
import 'package:emulator/core/base/messages/cpu_output_messages.dart';
import 'package:flutter/material.dart';

abstract class EmulatorScreen extends StatefulWidget {
  const EmulatorScreen({
    super.key,
    required this.width,
    required this.height,
    this.scale = 1,
  });

  final int width;
  final int height;
  final double scale;

  @override
  EmulatorScreenState createState();
}

abstract class EmulatorScreenState<SCREEN extends EmulatorScreen> extends State<SCREEN> with comms.Listener<CPUOutputMessage> {
  EmulatorScreenState() {
    listen();
  }
}
