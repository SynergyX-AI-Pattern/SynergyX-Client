import 'package:flutter/material.dart';

class EmotionHeader extends StatelessWidget {
  const EmotionHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        SizedBox(height: 10),
        Text('AI 감정 투자 일기', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        SizedBox(height: 4),
        Text(
          '입력한 투자 일기를 AI가 감정 분석하여\n감정 상태와 투자 조언을 제공해드립니다.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
