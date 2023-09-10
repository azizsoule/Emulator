import 'dart:async';

import 'package:flutter/material.dart';

abstract class EmulatorScreenEvent {}

class UpdateEmulatorScreenEvent extends EmulatorScreenEvent {}

abstract class EmulatorScreen extends StatefulWidget {
  EmulatorScreen({
    super.key,
    required this.width,
    required this.height,
    this.scale = 1,
  });

  final int width;
  final int height;
  final double scale;

  final StreamController<EmulatorScreenEvent> controller = StreamController();

  void update() {
    controller.add(UpdateEmulatorScreenEvent());
  }

  @override
  EmulatorScreenState createState();
}

abstract class EmulatorScreenState extends State<EmulatorScreen> {
  @override
  void initState() {
    super.initState();
    widget.controller.stream.listen(screenEventsListener);
  }

  void screenEventsListener(EmulatorScreenEvent event) {
    if (event is UpdateEmulatorScreenEvent) {
      setState(() {});
    }
  }
}
