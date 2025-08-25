import 'package:flutter/material.dart';

class EmotionAnalysisCard extends StatelessWidget {
  final List<String> emotions;
  final String summary;
  final String feedback;

  const EmotionAnalysisCard({
    super.key,
    required this.emotions,
    required this.summary,
    required this.feedback,
  });

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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.sentiment_satisfied_alt, color: Colors.orange),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '감정 분석: ${emotions.join(", ")}',
                      softWrap: true,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text('💡 투자 조언: $feedback'),
              const SizedBox(height: 10),
              Text('📝 오늘의 일기: $summary'),
            ],
          ),
          ),
        ),
      );
  }
}
