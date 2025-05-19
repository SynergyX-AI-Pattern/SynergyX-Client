import 'package:flutter/material.dart';

class MypageScreen extends StatelessWidget {
  const MypageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mypage Screen'),
      ),
      body: const Center(
        child: Text('마이페이지'),
      ),
    );
  }
}
