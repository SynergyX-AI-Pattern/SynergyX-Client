import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stockapp/screens/search_info_screen.dart';
import 'package:stockapp/services/backtest_service.dart';

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

  Future<void> _runBacktest() async {
    if (_selectedSymbol == null) return;

    setState(() => _loading = true);

    final simulatedResult = await BacktestService.run(
      pattern: widget.patternData,
      symbol: _selectedSymbol!,
      stockName: _selectedName ?? _selectedSymbol!,
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
      appBar: AppBar(      backgroundColor: Colors.white,
          title: const Text('백테스트 실행')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
            ElevatedButton(
              onPressed: (_selectedSymbol != null && !_loading) ? _runBacktest : null,
              child: _loading ? const CircularProgressIndicator() : const Text('백테스트 시작'),
            ),
            const SizedBox(height: 24),
            if (_result != null) ...[
              const Divider(),
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
    );
  }
}