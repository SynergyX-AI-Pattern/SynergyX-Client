import 'package:flutter/material.dart';
import 'package:stockapp/models/pattern.dart';
import 'package:stockapp/widgets/common/app_button.dart';
import 'package:stockapp/widgets/common/pattern_line_chart.dart';

class PatternPickCard extends StatelessWidget {
  final Pattern pattern;
  final VoidCallback? onApply; // 로딩 중이면 null로 비활성화
  final bool applying;

  const PatternPickCard({
    super.key,
    required this.pattern,
    required this.onApply,
    required this.applying,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: const Color(0xFFF4F4F4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              pattern.patternName,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
            ),
            Container(
                color: Colors.white,
                child: PatternLineChart(points: pattern.points)
            ),
            const SizedBox(height: 12),
            AppButton(label: '적용', onPressed: onApply)
          ],
        ),
      ),
    );
  }
}
