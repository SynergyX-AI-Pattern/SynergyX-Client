import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class PatternLineChart extends StatelessWidget {
  final List<num> points;
  final double height;
  final Color lineColor;
  final bool showDots;
  final bool showGrid;

  /// points: [100, 95, 110, ...]
  const PatternLineChart({
    super.key,
    required this.points,
    this.height = 150,
    this.lineColor = Colors.amber,
    this.showDots = true,
    this.showGrid = true,
  });

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return const SizedBox.shrink();

    // num -> double로 통일
    final values = points.map((e) => e.toDouble()).toList();

    // reduce에 math.max 직접 쓰지 말고 타입 맞는 람다 사용
    final double maxVal = values.reduce((a, b) => a > b ? a : b);
    final double safeMaxY = maxVal <= 0 ? 1.0 : maxVal; // 0 방지

    // Y축 뒤집기: (max - value)
    final spots = List<FlSpot>.generate(
      values.length,
          (i) => FlSpot(i.toDouble(), safeMaxY - values[i]),
    );

    // interval은 확실히 double로
    final double horizontalInterval =
    math.max((safeMaxY / 5).ceilToDouble(), 1.0);
    final double verticalInterval =
    math.max((values.length / 6).ceilToDouble(), 1.0);

    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: (values.length - 1).toDouble(),
          minY: 0,
          maxY: safeMaxY,
          titlesData: FlTitlesData(show: false),
          gridData: FlGridData(
            show: showGrid,
            drawHorizontalLine: true,
            drawVerticalLine: true,
            horizontalInterval: horizontalInterval,
            verticalInterval: verticalInterval,
            getDrawingHorizontalLine: (_) => FlLine(
              color: Colors.grey.withOpacity(0.3),
              strokeWidth: 1.0,
            ),
            getDrawingVerticalLine: (_) => FlLine(
              color: Colors.grey.withOpacity(0.3),
              strokeWidth: 1.0,
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.black12, width: 1.0),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: false,
              color: lineColor,
              barWidth: 2.0,
              dotData: FlDotData(show: showDots),
            ),
          ],
        ),
      ),
    );
  }
}
