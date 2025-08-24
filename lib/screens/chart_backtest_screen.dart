//chart_backtest_screen

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stockapp/screens/search_info_screen.dart';
import 'package:stockapp/data/backtest_api.dart';
import 'package:stockapp/screens/backtest_result_screen.dart'; // ← 결과 페이지 import 추가

class ChartBacktestScreen extends StatefulWidget {
  final Map<String, dynamic> patternData;

  const ChartBacktestScreen({super.key, required this.patternData});

  @override
  State<ChartBacktestScreen> createState() => _ChartBacktestScreenState();
}

class _ChartBacktestScreenState extends State<ChartBacktestScreen> {
  bool _loading = false;
  String? _selectedSymbol;
  int? _selectedStockId;
  DateTime? _startDate;
  DateTime? _endDate;

  Future<void> _runBacktest() async {
    if (_selectedStockId == null) return;

    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('시작일과 종료일을 모두 선택하세요')),
      );
      return;
    }

    if (_endDate!.difference(_startDate!).inDays < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('기간은 최소 2일 이상이어야 합니다')),
      );
      return;
    }

    setState(() => _loading = true);

    final simulatedResult = await BacktestService.run(
      patternId: widget.patternData['id'],
      stockId: _selectedStockId!,
      startDate: _startDate!,
      endDate: _endDate!,
    );

    setState(() => _loading = false);

    // JSON 파일 저장
    final ts = widget.patternData['timestamp'];
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/pattern_$ts.json');
    final updated = Map<String, dynamic>.from(widget.patternData);
    updated['backtestResult'] = simulatedResult;
    await file.writeAsString(jsonEncode(updated));

    // 결과 페이지로 이동 (수정본)
    if (mounted) {
      final merged = {
        ...simulatedResult, // 서버 응답 { isSuccess, code, result: {...} }

        // 루트에도 보정 필드 싣기
        'stockId': _selectedStockId,
        'stockName': _selectedSymbol,

        // 서버가 안 준 필드를 result 안에도 안전하게 주입
        'result': {
          ...simulatedResult['result'],
          'stockId': simulatedResult['result']?['stockId'] ?? _selectedStockId,
          'stockName': simulatedResult['result']?['stockName'] ?? _selectedSymbol,
        },
      };

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BacktestResultScreen(result: merged),
        ),
      );
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, title: const Text('백테스트 실행')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  side: const BorderSide(color: Colors.black12),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const StockSearchPage(),
                    ),
                  ).then((next) {
                    if (!mounted || next is! Map<String, dynamic>) return;

                    setState(() {
                      _selectedSymbol = next['symbol'];
                      _selectedStockId = next['id'];
                    });
                  });
                },
                child: Text(_selectedSymbol == null ? '종목 선택' : '선택된 종목: $_selectedSymbol'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      side: const BorderSide(color: Colors.black12),
                    ),
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      side: const BorderSide(color: Colors.black12),
                    ),
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  side: const BorderSide(color: Colors.black12),
                ),
                onPressed: (_selectedStockId != null && !_loading) ? _runBacktest : null,
                child: _loading
                    ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Text('백테스트 시작'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
