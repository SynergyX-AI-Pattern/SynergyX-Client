import 'package:flutter/material.dart';

class InterestScreen extends StatelessWidget {
  const InterestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Interest Screen'),
      ),
      body: const Center(
        child: Text('관심종목 페이지'),
      ),
    );
  }
}
