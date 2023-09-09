import 'dart:async';

import 'package:flutter/material.dart';

abstract class EmulatorScreen extends StatefulWidget {
  EmulatorScreen({
    super.key,
  });

  final StreamController<EmulatorScreenEvent> controller = StreamController();

  void update() {
    controller.add(EmulatorScreenEvent.update);
  }

  @override
  EmulatorScreenState createState();
}

abstract class EmulatorScreenState extends State<EmulatorScreen> {
  void _listen() {
    widget.controller.stream.listen((event) {
      if (event == EmulatorScreenEvent.update) {
        setState(() {});
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _listen();
  }
}

enum EmulatorScreenEvent {
  clear,
  update;
}
