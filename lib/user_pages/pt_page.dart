import 'package:flutter/material.dart';

class PtPage extends StatelessWidget {
  const PtPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'PT Page - Allenamento',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}