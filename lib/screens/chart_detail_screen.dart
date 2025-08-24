//chart_detail_screen

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;

import 'package:stockapp/screens/search_info_screen.dart';
import 'package:stockapp/screens/chart_edit_screen.dart';
import 'package:stockapp/screens/chart_backtest_screen.dart';
import 'package:stockapp/data/pattern_api.dart';
import 'package:stockapp/models/pattern.dart';

class PatternDetailPage extends StatefulWidget {
  final Pattern pattern;

  const PatternDetailPage({super.key, required this.pattern});

  @override
  State<PatternDetailPage> createState() => _PatternDetailPageState();
}

class _PatternDetailPageState extends State<PatternDetailPage> {
  late Map<String, dynamic> data;
  late List<dynamic> appliedStockList;
  late TextEditingController _titleController;

  /// 패턴 포인트를 선 그래프로 그리는 위젯
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

  Widget _buildResultChart(List<dynamic>? curve) {
    if (curve == null || curve.isEmpty) {
      return const Center(child: Text('차트 데이터 없음'));
    }

    final spots = <FlSpot>[];
    for (int i = 0; i < curve.length; i++) {
      final point = curve[i];
      final value = (point['value'] as num).toDouble();
      spots.add(FlSpot(i.toDouble(), value));
    }

    return LineChart(
      LineChartData(
        titlesData: FlTitlesData(show: false),
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.blue,
            barWidth: 2,
            dotData: FlDotData(show: false),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    data = widget.pattern.toJson();
    appliedStockList = List.from(data['appliedStockList'] ?? []);
    _titleController = TextEditingController(text: widget.pattern.patternName);
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  PatternRequest _buildPatternRequestFromData() {
    // 기존 패턴 정보를 기반으로 서버에 보낼 요청 객체 생성
    return PatternRequest(
      patternId: data['id'] ?? DateTime.now().millisecondsSinceEpoch,
      patternName: data['title'] ?? data['patternName'] ?? '이름없는 패턴',
      points:
      (data['points'] is List)
          ? List<int>.from(
        data['points'].map((e) => int.tryParse(e.toString()) ?? 0),
      )
          : [],
      tolerance:
      (data['tolerance'] is String)
          ? double.tryParse(data['tolerance']) ?? 0.0
          : (data['tolerance'] as num?)?.toDouble() ?? 0.0,
      periodValue:
      (data['periodValue'] is String)
          ? int.tryParse(data['periodValue']) ?? 0
          : (data['periodValue'] as num?)?.toInt() ?? 0,
      periodUnit: data['periodUnit'] ?? 'HOUR',
    );
  }

  Future<void> _saveTitle(String title) async {
    data['title'] = title;
    final rawId = data['id'];
    final int id = (rawId is int) ? rawId : int.parse(rawId.toString());
    await PatternApi.updatePattern(id, _buildPatternRequestFromData());
    if (mounted) setState(() {});
  }

  Future<void> _deletePattern() async {
    final rawId = data['id'];
    final int id = (rawId is int) ? rawId : int.parse(rawId.toString());
    await PatternApi.deletePattern(id);
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  Future<void> _applyStock(String result) async {
    final updatedData = Map<String, dynamic>.from(data);
    if (updatedData['appliedStockList'] == null ||
        updatedData['appliedStockList'] is! List) {
      updatedData['appliedStockList'] = [];
    }
    final current = List<Map<String, dynamic>>.from(
      updatedData['appliedStockList'],
    );
    final alreadyExists = current.any((item) => item['symbol'] == result);
    if (!alreadyExists) {
      current.add({'symbol': result, 'name': result});
      updatedData['appliedStockList'] = current;
      final id = updatedData['id'];
      setState(() {
        data = updatedData;
        appliedStockList = current;
      });
      await PatternApi.updatePattern(id, _buildPatternRequestFromData());
    }
  }

  void _handlePatternUpdate(Map<String, dynamic> updatedMap) {
    final updatedPattern = Pattern.fromJson(updatedMap);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => PatternDetailPage(pattern: updatedPattern),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final periodValue = widget.pattern.periodValue;
    final periodUnit = widget.pattern.periodUnit;
    final tolerance = widget.pattern.tolerance;
    final backtest = data['backtestResult'];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: '패턴 이름 입력',
                ),
                style: const TextStyle(color: Colors.black, fontSize: 18),
                onSubmitted: _saveTitle,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: () => _saveTitle(_titleController.text),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.play_arrow),
            tooltip: '백테스트 실행',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChartBacktestScreen(patternData: data),
                ),
              );
            },
          ),
          IconButton(icon: const Icon(Icons.delete), onPressed: _deletePattern),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              side: const BorderSide(color: Colors.black12),
            ),
            onPressed: () async {
              final updatedMap = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => ChartEditPage(
                    patternData: Map<String, dynamic>.from(data),
                    onSaved: () async {
                      final rawId = data['id'];
                      final int id =
                      (rawId is int)
                          ? rawId
                          : int.parse(rawId.toString());
                      final pattern = await PatternApi.getPatternDetail(id);
                      return pattern.toJson();
                    },
                  ),
                ),
              );

              if (updatedMap is Map<String, dynamic>) {
                _handlePatternUpdate(updatedMap);
              }
            },
            child: const Text('패턴 수정'),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                color: Colors.white,
                elevation: 3, // 살짝 그림자
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(50.0), // 카드 안쪽 여백
                  child: SizedBox(
                    width: double.infinity,
                    child: _buildPatternChart(widget.pattern.points),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '적용 종목:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        side: const BorderSide(color: Colors.black12), // 테두리 살짝
                      ),
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const StockSearchPage(),
                          ),
                        );
                        if (result is Map<String, dynamic> &&
                            result['symbol'] is String) {
                          await _applyStock(result['symbol']);
                        }
                      },
                      child: const Text('종목 변경'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                appliedStockList.isNotEmpty
                    ? Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children:
                  appliedStockList.asMap().entries.map<Widget>((entry) {
                    final index = entry.key;
                    final stock = entry.value;
                    return Chip(
                      label: Text(stock['name'] ?? stock['symbol']),
                      deleteIcon: const Icon(Icons.close),
                      onDeleted: () async {
                        appliedStockList.removeAt(index);
                        data['appliedStockList'] = appliedStockList;
                        final id = data['id'];
                        setState(() {});
                        await PatternApi.updatePattern(
                          id,
                          _buildPatternRequestFromData(),
                        );
                      },
                    );
                  }).toList(),
                )
                    : const Text('없음'),
                const SizedBox(height: 16),
                Text(
                  '기간: $periodValue $periodUnit',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  '오차 범위: ${tolerance.toStringAsFixed(1)}%',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                if (backtest != null) ...[
                  const Divider(),
                  const Text(
                    '백테스트 결과',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 200,
                    child: _buildResultChart(
                      backtest['equityCurve'] as List<dynamic>?,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('종목: ${backtest['stockName']} (${backtest['symbol']})'),
                  Text('매칭 횟수: ${backtest['matchedCount']}회'),
                  Text('승률: ${backtest['winRate']}%'),
                  Text('평균 수익률: ${backtest['averageReturn']}%'),
                  Text(
                    '최대 수익률: ${backtest['maxReturn']}% (${backtest['maxReturnDate']})',
                  ),
                  Text('기간: ${backtest['startDate']} ~ ${backtest['endDate']}'),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
