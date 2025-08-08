import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:path_provider/path_provider.dart';
import 'package:stockapp/screens/search_info_screen.dart';
import 'package:stockapp/data/backtest_api.dart';

class ChartBacktestScreen extends StatefulWidget {
  final Map<String, dynamic> patternData;

  const ChartBacktestScreen({super.key, required this.patternData});

  @override
  State<ChartBacktestScreen> createState() => _ChartBacktestScreenState();
}

class _ChartBacktestScreenState extends State<ChartBacktestScreen> {
  bool _loading = false;
  Map<String, dynamic>? _result;
  String? _selectedSymbol;
  String? _selectedName;
  DateTime? _startDate; // 백테스트 시작일
  DateTime? _endDate; // 백테스트 종료일

  /// 백테스트 결과의 추세를 그리기 위한 차트를 생성
  Widget _buildResultChart(List<dynamic>? curve) {
    if (curve == null || curve.isEmpty) {
      return const Center(child: Text('차트 데이터 없음'));
    }

    // API에서 받은 데이터를 LineChart에 필요한 좌표로 변환
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

  Future<void> _runBacktest() async {
    if (_selectedSymbol == null) return;
    // 시작/종료 날짜가 모두 선택되었는지 확인
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('시작일과 종료일을 모두 선택하세요')),
      );
      return;
    }
    // 최소 2일 이상의 기간인지 검증
    if (_endDate!.difference(_startDate!).inDays < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('기간은 최소 2일 이상이어야 합니다')),
      );
      return;
    }

    setState(() => _loading = true);

    final simulatedResult = await BacktestService.run(
      pattern: widget.patternData,
      symbol: _selectedSymbol!,
      stockName: _selectedName ?? _selectedSymbol!,
      startDate: _startDate!,
      endDate: _endDate!,
    );

    setState(() {
      _loading = false;
      _result = simulatedResult;
    });

    final ts = widget.patternData['timestamp'];
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/pattern_$ts.json');
    final updated = Map<String, dynamic>.from(widget.patternData);
    updated['backtestResult'] = simulatedResult;
    await file.writeAsString(jsonEncode(updated));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white,
          title: const Text('백테스트 실행')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const StockSearchPage(),
                  ),
                ).then((next) {
                  if (!mounted || next is! String) return;

                  setState(() {
                    _selectedSymbol = next;
                    _selectedName = next;
                    _result = null;
                  });
                });
              },
              child: Text(_selectedSymbol == null ? '종목 선택' : '선택된 종목: $_selectedSymbol'),
            ),
            const SizedBox(height: 16),

            // 시작일과 종료일을 선택하는 버튼들
            Row(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _startDate ?? DateTime.now().subtract(const Duration(days: 7)),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() => _startDate = picked);
                    }
                  },
                  child: Text(
                    _startDate == null
                        ? '시작일 선택'
                        : '시작일: ${_startDate!.toIso8601String().split('T').first}',
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _endDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() => _endDate = picked);
                    }
                  },
                  child: Text(
                    _endDate == null
                        ? '종료일 선택'
                        : '종료일: ${_endDate!.toIso8601String().split('T').first}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: (_selectedSymbol != null && !_loading) ? _runBacktest : null,
              child: _loading
                  ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Text('백테스트 시작'),
            ),
            const SizedBox(height: 24),
            if (_result != null) ...[
              const Divider(),
              SizedBox(
                height: 200,
                child: _buildResultChart(_result!['equityCurve'] as List<dynamic>?),
              ),
              const SizedBox(height: 8),
              Text('종목: ${_result!['stockName']} (${_result!['symbol']})'),
              Text('매칭 횟수: ${_result!['matchedCount']}회'),
              Text('승률: ${_result!['winRate']}%'),
              Text('평균 수익률: ${_result!['averageReturn']}%'),
              Text('최대 수익률: ${_result!['maxReturn']}% (${_result!['maxReturnDate']})'),
              Text('기간: ${_result!['startDate']} ~ ${_result!['endDate']}'),
            ]
          ],
        ),
      ),
      ),
    );
  }
}