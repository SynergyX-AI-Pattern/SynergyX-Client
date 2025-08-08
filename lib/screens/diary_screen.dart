import 'package:flutter/material.dart';
import 'package:stockapp/widgets/emotion_diary/DairyBubble.dart';
import 'package:stockapp/widgets/emotion_diary/EmotionAnalysisCard.dart';
import 'package:stockapp/widgets/emotion_diary/EmotionHeader.dart';
import 'package:stockapp/widgets/emotion_diary/EmotionInputBar.dart';

class DairyScreen extends StatelessWidget {
  const DairyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const EmotionHeader(),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                children: const [
                  SizedBox(height: 12),
                  DiaryBubble(
                    text:
                    '오늘 삼성전자 주식을 매도했는데 내가 사고 나서 떡락해서 진짜 너무 화난다 ㅡㅡ',
                  ),
                  SizedBox(height: 12),
                  EmotionAnalysisCard(),
                  SizedBox(height: 20),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: EmotionInputBar(),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
