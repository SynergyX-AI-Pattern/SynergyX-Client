//chart_screen

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;

import 'package:stockapp/data/pattern_api.dart';
import 'package:stockapp/models/pattern.dart';


import 'package:stockapp/screens/chart_detail_screen.dart';
import 'package:stockapp/screens/chart_new_screen.dart';

class ChartScreen extends StatefulWidget {
  const ChartScreen({super.key});

  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  // 서버에서 받아온 패턴 리스트
  List<Pattern> patterns = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPatterns();
  }

  /// 서버에서 패턴 목록을 불러오는 함수
  Future<void> _fetchPatterns() async {
    try {
      final result = await PatternApi.getPatterns();
      if (!mounted) return;
      setState(() {
        patterns = result;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('패턴 불러오기 실패: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ 서버 패턴 로딩 실패: ${e.toString()}')),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  // [ADDED] 패턴 생성 화면으로 이동한 뒤, 성공 시 목록 새로고침
  Future<void> _navigateToCreatePattern() async {
    try {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ChartNewScreen()),
      );

      // ChartNewScreen이 무엇을 반환하든(예: true, 생성된 id, json 등),
      // null만 아니면 생성된 것으로 보고 새로고침
      if (!mounted) return;
      if (result != null) {
        await _fetchPatterns();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ 패턴이 생성되었습니다.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('패턴 생성 중 오류가 발생했어요. ($e)')),
      );
    }
  }

  /// 패턴 상세 페이지로 이동
  Future<void> _openDetail(Pattern pattern) async {
    try {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PatternDetailPage(pattern: pattern),
        ),
      );
      // 상세에서 수정/삭제가 이루어졌을 수 있으니 돌아오면 새로고침
      if (!mounted) return; // [ADDED]
      await _fetchPatterns(); // [ADDED]
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('상세 화면을 여는 중 오류가 발생했어요. ($e)')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final body = isLoading
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
      itemCount: patterns.length,
      itemBuilder: (context, index) {
        final pattern = patterns[index];

        return Card(
          margin: const EdgeInsets.all(8),
          color: Colors.white, // 카드 배경 흰색
          child: ListTile(
            // 카드 내부 여백(좌우/상하)
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

            // leading과 텍스트 사이 간격 → leading을 Padding으로 감싸기
            leading: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: SizedBox(
                width: 100,
                height: 100,
                child: _buildPatternChart(pattern.points),
              ),
            ),

            // 전체 색상 통일
            textColor: Colors.black,
            iconColor: Colors.black,

            title: Text(pattern.patternName),
            subtitle: Text('오차 ${pattern.tolerance}, 기간 ${pattern.periodValue} ${pattern.periodUnit}'),
            onTap: () => _openDetail(pattern),
          ),
        );
      },
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white,title: const Text('서버 패턴 목록')),
      body: body,

      // [ADDED] 패턴 추가 버튼
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreatePattern,
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// 패턴 포인트를 선 차트로 그려주는 위젯
/// 패턴 포인트를 선 그래프로 그리는 위젯 (y축 반전)
Widget _buildPatternChart(List<int> points) {
  if (points.isEmpty) {
    return const SizedBox.shrink();
  }

  // 저장된 y의 최고값 (정규화가 0~100이면 double maxY = 100; 로 고정)
  final double maxY = points.reduce(math.max).toDouble();

  final spots = <FlSpot>[
    for (int i = 0; i < points.length; i++)
    // y 반전: 화면좌표(아래로 클수록 큼) -> 그래프좌표(위로 클수록 큼)
      FlSpot(i.toDouble(), (maxY - points[i]).toDouble()),
  ];

  return LineChart(
    LineChartData(
      minX: 0,
      maxX: (points.length - 1).toDouble(),
      minY: 0,
      maxY: maxY,
      titlesData: FlTitlesData(show: false),
      gridData: FlGridData(show: false),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: false,
          color: Colors.blue,
          barWidth: 2,
          dotData: FlDotData(show: false),
        ),
      ],
    ),
  );
}