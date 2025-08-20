// lib/widgets/interest/pattern/pattern_chart_card.dart
import 'package:flutter/material.dart';

class PatternChartCard extends StatelessWidget {
  final List<num> points;
  const PatternChartCard({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
    // TODO: fl_chart 등으로 라인차트 교체
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: const Center(child: Text('패턴 라인 차트 영역')),
    );
  }
}
