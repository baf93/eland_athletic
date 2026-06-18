import 'package:flutter/material.dart';

void main() {
  runApp(const ProApp());
}

class ProApp extends StatelessWidget {
  const ProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Eland Pro",
      home: const Scaffold(
        body: Center(child: Text('Pannello Trainer / Nutrizionista')),
      ),
    );
  }
}