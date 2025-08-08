import 'package:flutter/material.dart';

class EmotionHeader extends StatelessWidget {
  const EmotionHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        Text('ai 감정 투자 일기', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        SizedBox(height: 4),
        Text(
          '~~~감정 투자일기에 관한\n간단한 설명~~~',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 6,),
        Text('2025년 8월 3일', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),)
      ],
    );
  }
}
