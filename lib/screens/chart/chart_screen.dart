import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;

import 'package:stockapp/data/pattern_api.dart';
import 'package:stockapp/models/pattern.dart';

import 'package:stockapp/screens/chart/chart_detail_screen.dart';
import 'package:stockapp/screens/chart/chart_new_screen.dart';

class ChartScreen extends StatefulWidget {
  const ChartScreen({super.key});

  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  List<Pattern> patterns = [];
  bool isLoading = true;
  bool isLoadingMore = false;

  bool _isLastPage = false; // 서버 페이징 없음 → 한 번만 불러오기
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchPatterns();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200 &&
        !isLoadingMore &&
        !_isLastPage) {
      _fetchPatterns(loadMore: true);
    }
  }

  Future<void> _fetchPatterns({bool loadMore = false, bool forceReload = false}) async {
    if (_isLastPage && !forceReload) return;

    try {
      if (forceReload) {
        setState(() {
          isLoading = true;
          patterns.clear();
          _isLastPage = false;
        });
      } else if (loadMore) {
        setState(() => isLoadingMore = true);
      } else {
        setState(() => isLoading = true);
      }

      final result = await PatternApi.getPatterns();

      if (!mounted) return;
      setState(() {
        patterns = result;
        _isLastPage = true;
        isLoading = false;
        isLoadingMore = false;
      });
    } catch (e) {
      debugPrint('패턴 불러오기 실패: $e');
      if (!mounted) return;
      setState(() {
        isLoading = false;
        isLoadingMore = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ 서버 패턴 로딩 실패: $e')),
      );
    }
  }

  Future<void> _navigateToCreatePattern() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ChartNewScreen()),
    );
    if (result == true) {
      await _fetchPatterns(forceReload: true);
    }
  }

  Future<void> _openDetail(Pattern pattern) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PatternDetailPage(patternId: pattern.patternId),
      ),
    );
    if (result == true) {
      await _fetchPatterns(forceReload: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final body = isLoading
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
      controller: _scrollController,
      itemCount: patterns.length + (isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= patterns.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final pattern = patterns[index];
        return GestureDetector(
          onTap: () => _openDetail(pattern),
          child: Card(
            margin: const EdgeInsets.all(12),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            elevation: 0,
            color: const Color(0x4DD9D9D9),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 패턴 이름
                  Text(
                    pattern.patternName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: SizedBox(
                      height: 150,
                      child: _buildPatternChart(pattern.points),
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    "최근 백테스팅 결과",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),

                  if (pattern.recentBacktestResults.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (final bt in pattern.recentBacktestResults.take(3))
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE6E6E6), // 결과 박스 회색
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${bt.executedAt} | ${bt.stockName}",
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "평균수익률: ${bt.averageReturn.toStringAsFixed(2)}%   "
                                      "승률: ${bt.winRate.toStringAsFixed(1)}%   "
                                      "매칭: ${bt.matchedCount}",
                                ),
                              ],
                            ),
                          ),
                      ],
                    )
                  else
                    const Text("백테스트 결과 없음",
                        style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),
        );
      },
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('전략 패턴'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black),
            onPressed: _navigateToCreatePattern,
          ),
        ],
      ),
      body: body,
    );
  }
}

/// 패턴 차트 (직선 + 자동 격자)
Widget _buildPatternChart(List<int> points) {
  if (points.isEmpty) return const SizedBox.shrink();

  final double maxY = points.reduce(math.max).toDouble();
  final spots = <FlSpot>[
    for (int i = 0; i < points.length; i++)
      FlSpot(i.toDouble(), (maxY - points[i]).toDouble()),
  ];

  return LineChart(
    LineChartData(
      minX: 0,
      maxX: (points.length - 1).toDouble(),
      minY: 0,
      maxY: maxY,
      titlesData: FlTitlesData(show: false),
      gridData: FlGridData(
        show: true,
        drawHorizontalLine: true,
        drawVerticalLine: true,
        horizontalInterval: (maxY / 5).ceilToDouble(),
        verticalInterval: (points.length / 6).ceilToDouble(),
        getDrawingHorizontalLine: (value) => FlLine(
          color: Colors.grey.withValues(alpha: 0.3),
          strokeWidth: 1,
        ),
        getDrawingVerticalLine: (value) => FlLine(
          color: Colors.grey.withValues(alpha: 0.3),
          strokeWidth: 1,
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: Colors.black12),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: false,
          color: Colors.amber,
          barWidth: 2,
          dotData: FlDotData(show: true),
        ),
      ],
    ),
  );
}
