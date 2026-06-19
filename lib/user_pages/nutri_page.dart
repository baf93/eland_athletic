import 'package:flutter/material.dart';

class NutriPage extends StatelessWidget {
  const NutriPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Nutri Page - Alimentazione',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}