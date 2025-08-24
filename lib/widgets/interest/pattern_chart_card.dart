// lib/widgets/interest/pattern/pattern_chart_card.dart
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class PatternChartCard extends StatelessWidget {
  final List<num> points;          // API의 pattern.points
  final double? tolerancePct;      // API의 tolerance(%)이면 2.5 -> 2.5
  final EdgeInsets padding;

  const PatternChartCard({
    super.key,
    required this.points,
    this.tolerancePct,
    this.padding = const EdgeInsets.all(12),
  });

  @override
  Widget build(BuildContext context) {
    if (points.length < 2) {
      return _placeholder();
    }

    // spots 변환 (x = 인덱스, y = 값)
    final spots = List<FlSpot>.generate(
      points.length,
          (i) => FlSpot(i.toDouble(), points[i].toDouble()),
    );

    // y축 범위 계산 + 여유 패딩
    final ys = points.map((e) => e.toDouble()).toList();
    double minY = ys.reduce(min);
    double maxY = ys.reduce(max);
    final pad = max(1.0, (maxY - minY) * 0.1);
    minY -= pad;
    maxY += pad;

    // 허용오차 밴드(선택)
    LineChartBarData? upperLine;
    LineChartBarData? lowerLine;
    List<BetweenBarsData>? between;

    if (tolerancePct != null && tolerancePct! > 0) {
      final tol = tolerancePct! / 100.0;
      final uppers = List<FlSpot>.generate(
        points.length, (i) => FlSpot(i.toDouble(), ys[i] * (1 + tol)),
      );
      final lowers = List<FlSpot>.generate(
        points.length, (i) => FlSpot(i.toDouble(), ys[i] * (1 - tol)),
      );

      upperLine = LineChartBarData(
        spots: uppers,
        isCurved: true,
        barWidth: 0,                       // 선은 보이지 않게
        dotData: const FlDotData(show: false),
        color: Colors.transparent,
      );
      lowerLine = LineChartBarData(
        spots: lowers,
        isCurved: true,
        barWidth: 0,
        dotData: const FlDotData(show: false),
        color: Colors.transparent,
      );
      between = [
        BetweenBarsData(
          fromIndex: 1, // lowerLine의 인덱스 (아래에서 순서 맞춰줌)
          toIndex: 0,   // upperLine의 인덱스
          color: Colors.amber.withOpacity(0.12),
        ),
      ];

      // y범위 재보정(밴드가 더 넓어질 수 있음)
      minY = min(minY, lowers.map((e) => e.y).reduce(min));
      maxY = max(maxY, uppers.map((e) => e.y).reduce(max));
    }

    // 메인 패턴 선
    final patternLine = LineChartBarData(
      spots: spots,
      isCurved: true,
      barWidth: 2,
      color: Colors.amber,                 // 디자인에 맞게
      dotData: const FlDotData(show: true),
    );

    // 라벨/그리드 최소화
    final titles = FlTitlesData(
      bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );

    return Container(
      height: 180,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: LineChart(
        LineChartData(
          minY: minY,
          maxY: maxY,
          minX: 0,
          maxX: (spots.length - 1).toDouble(),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: (maxY - minY) / 4,
            getDrawingHorizontalLine: (_) => FlLine(
              color: Colors.grey.withOpacity(0.2),
              strokeWidth: 1,
            ),
          ),
          titlesData: titles,
          borderData: FlBorderData(show: false),
          lineBarsData: [
            // betweenBars를 쓰려면 순서: [upper, lower, main]
            if (upperLine != null) upperLine,
            if (lowerLine != null) lowerLine,
            patternLine,
          ],
          betweenBarsData: between ?? const [],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      height: 180,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: const Text('표시할 패턴 데이터가 없습니다.'),
    );
  }
}
