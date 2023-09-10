import 'dart:async';

import 'package:flutter/material.dart';

abstract class EmulatorScreenEvent {}

class UpdateEmulatorScreenEvent extends EmulatorScreenEvent {
  final void Function()? callback;

  UpdateEmulatorScreenEvent(this.callback);
}

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

  void update([void Function()? callback]) {
    controller.add(
      UpdateEmulatorScreenEvent(callback),
    );
  }

  @override
  EmulatorScreenState createState();
}

abstract class EmulatorScreenState<SCREEN extends EmulatorScreen> extends State<SCREEN> {
  @override
  void initState() {
    super.initState();
    widget.controller.stream.listen(screenEventListener);
  }

  void screenEventListener(EmulatorScreenEvent event) {
    if (event is UpdateEmulatorScreenEvent) {
      setState(() => event.callback?.call());
    }
  }
}
