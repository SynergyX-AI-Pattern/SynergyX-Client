import 'package:flutter/material.dart';

class DairyScreen extends StatelessWidget {
  const DairyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dairy Screen'),
      ),
      body: const Center(
        child: Text('감정일기 페이지'),
      ),
    );
  }
}
