import 'package:flutter/material.dart';

void main() {
  runApp(const UserApp());
}

class UserApp extends StatelessWidget {
  const UserApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Eland Athletic",
      home: const Scaffold(
        body: Center(child: Text('Benvenuto nella User App!')),
      ),
    );
  }
}