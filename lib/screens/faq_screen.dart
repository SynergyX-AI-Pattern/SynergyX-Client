import 'package:flutter/material.dart';

/// FAQ(자주 묻는 질문) 화면
///
/// 서비스 이용과 관련된 질문과 답변을 제공합니다.
class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FAQ'),
      ),
      body: const Center(
        // 추후 상세 FAQ 목록이 들어갈 예정
        child: Text('FAQ 화면 (준비중)'),
      ),
    );
  }
}