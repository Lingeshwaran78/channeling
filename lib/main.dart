import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const methodChannel = MethodChannel("com.example.channeling/method");
  static const pressureChannel = EventChannel("com.example.channeling/event");

  String _sensorCheck = "";
  double _pressureReading = 0;
  late StreamSubscription pressureSubscription;

  Future accessMethodChannel() async {
    try {
      var result = await methodChannel.invokeMethod("getMethodChannel");
      setState(() {
        _sensorCheck = result.toString();
      });
    } on PlatformException catch (e) {
      log("Catching Error :: $e");
    }
  }

  Future accessStartEvent() async {
    try {
      pressureSubscription =
          pressureChannel.receiveBroadcastStream().listen((event) {
        setState(() {
          _pressureReading = event;
        });
      });
    } catch (e) {
      log("Pressure Error :: $e");
    }
  }

  stopEvent() {
    setState(() {
      _pressureReading = 0;
    });
    pressureSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Hello World'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Sensor Check  $_sensorCheck"),
            ElevatedButton(
              onPressed: () => accessMethodChannel(),
              child: const Text("Check Availability"),
            ),
            Text("Pressure Reading $_pressureReading"),
            ElevatedButton(
              onPressed: () => accessStartEvent(),
              child: const Text("Start Reading"),
            ), ElevatedButton(
              onPressed: () => stopEvent(),
              child: const Text("Stop Reading"),
            ),
          ],
        ),
      ),
    );
  }
}
