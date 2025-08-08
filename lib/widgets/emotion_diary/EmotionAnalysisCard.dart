import 'package:flutter/material.dart';

class EmotionAnalysisCard extends StatelessWidget {
  const EmotionAnalysisCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 224),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(8),
          ),
          child:
              Text(
                  style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
                  '감정 분석: 후회, 분노, 실망 \n투자 조언: 감정이 격한 날은 매매를 자제하는 것도 전략입니다. \n오늘의 일기: 삼성전자 매도 후 하락으로 큰 분노. 감정적 결정에 대해 되돌아보는 하루.'
              ),
          ),
        ),
      );
  }
}
