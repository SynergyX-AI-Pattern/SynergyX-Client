import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:stockapp/screens/search_info_screen.dart';
import 'package:stockapp/data/backtest_api.dart';
import 'package:stockapp/screens/backtest_result_screen.dart';
import 'package:stockapp/models/backtest_result.dart'; // 상세 결과 모델




class BacktestPopup extends StatefulWidget {
  final Map<String, dynamic> patternData;
  const BacktestPopup({super.key, required this.patternData});

  @override
  State<BacktestPopup> createState() => _BacktestPopupState();
}

class _BacktestPopupState extends State<BacktestPopup> {
  bool _loading = false;

  // 종목 선택
  int? _selectedStockId;
  String? _selectedSymbol;

  // 시작일 선택
  DateTime? _startDate;
  final _startDateController = TextEditingController();

  // 종료일 선택
  DateTime? _endDate;
  final _endDateController = TextEditingController();

  // 목표 수익률(선택)
  final _profitController = TextEditingController();

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    _profitController.dispose();
    super.dispose();
  }

  // patternId 안전 추출
  int? _extractPatternId(Map<String, dynamic> data) {
    final any = data['patternId'] ?? data['id'];
    if (any is int) return any;
    return int.tryParse(any?.toString() ?? '');
  }

  // 응답 표준화
  Map<String, dynamic> _normalizeResponse(dynamic resp) {
    if (resp is Map<String, dynamic>) {
      final r = resp['result'];
      if (r is Map<String, dynamic>) return r;
      return resp;
    }
    return {};
  }

  Future<void> _runBacktest() async {
    final patternId = _extractPatternId(widget.patternData);
    if (patternId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('패턴 ID가 유효하지 않습니다.')),
      );
      return;
    }
    if (_selectedStockId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('종목을 선택하세요.')),
      );
      return;
    }
    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('시작일을 선택하세요.')),
      );
      return;
    }

    setState(() => _loading = true);
    final endDate = DateTime.now();

    final raw = await BacktestService.run(
      patternId: patternId,
      stockId: _selectedStockId!,
      startDate: _startDate!,
      endDate: endDate,
    );

    if (_endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('종료일을 선택하세요.')),
      );
      return;
    }
    if (_startDate!.isAfter(_endDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('시작일이 종료일보다 늦습니다.')),
      );
      return;
    }

    setState(() => _loading = false);
    final normalized = _normalizeResponse(raw);

    // 결과 파일 저장(디버깅/오프라인 확인용)
    try {
      final dir = await getApplicationDocumentsDirectory();
      final ts = DateTime.now().millisecondsSinceEpoch;
      final file = File('${dir.path}/backtest_${patternId}_$ts.json');
      await file.writeAsString(jsonEncode({
        'patternId': patternId,
        'stockId': _selectedStockId,
        'symbol': _selectedSymbol,
        'startDate': _startDate!.toIso8601String(),
        'endDate': _endDate!.toIso8601String(),
        'result': normalized,
      }));
    } catch (_) {}

    if (!mounted) return;

    final mergedForScreen = <String, dynamic>{
      ...normalized,
      'stockId': normalized['stockId'] ?? _selectedStockId,
      'stockName': normalized['stockName'] ?? _selectedSymbol,
      'patternId': normalized['patternId'] ?? patternId,
      'startDate': normalized['startDate'] ?? _startDate!.toIso8601String().split('T').first,
      'endDate': normalized['endDate'] ?? _endDate!.toIso8601String().split('T').first,      'targetReturn': double.tryParse(_profitController.text),
    };

    // 팝업 닫고 결과 화면으로
    Navigator.of(context).pop();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => BacktestResultScreen(result: mergedForScreen)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final patternName = (widget.patternData['patternName'] ?? widget.patternData['title'] ?? '').toString();
    final periodValue = widget.patternData['periodValue'] ?? '';
    final periodUnit = (widget.patternData['periodUnit'] ?? 'DAY').toString();
    final tolerance = (widget.patternData['tolerance'] as num?)?.toDouble();

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: Material(
        color: Colors.white,                   // 팝업 카드 흰색
        elevation: 8,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== 헤더 =====
              Text(patternName.isNotEmpty ? patternName : '패턴',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  if (periodValue.toString().isNotEmpty)
                    _chip('기간: $periodValue $periodUnit'),
                  if (tolerance != null) _chip('허용 오차: ${tolerance.toStringAsFixed(2)}'),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(),

              const Text('백테스팅 설정',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),

              // 종목 선택
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.black12),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    final next = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const StockSearchPage()),
                    );
                    if (!mounted || next is! Map<String, dynamic>) return;
                    setState(() {
                      _selectedSymbol = next['symbol']?.toString();
                      final sid = next['id'];
                      _selectedStockId = sid is int ? sid : int.tryParse('$sid');
                    });
                  },
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(_selectedSymbol == null ? '종목 선택' : '선택된 종목: $_selectedSymbol'),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // 시작일
              TextField(
                controller: _startDateController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: '백테스팅 시작 날짜 설정',
                  suffixIcon: Icon(Icons.calendar_today),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _startDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                    // 날짜 피커 흰 배경 + 선택일 검정
                    builder: (context, child) {
                      final base = Theme.of(context);
                      return Theme(
                        data: base.copyWith(
                          dialogTheme: const DialogThemeData(      // ✅ DialogThemeData 로 수정
                            backgroundColor: Colors.white,
                          ),
                          colorScheme: const ColorScheme.light(
                            primary: Colors.black,
                            onPrimary: Colors.white,
                            surface: Colors.white,
                            onSurface: Colors.black,
                          ),
                          datePickerTheme: const DatePickerThemeData(
                            backgroundColor: Colors.white,         // ✅ DatePicker 자체 배경
                          ),
                        ),
                        child: child!,
                      );
                      },
                  );
                  if (picked != null) {
                    setState(() {
                      _startDate = picked;
                      _startDateController.text = picked.toIso8601String().split('T').first;

                      // 시작일이 종료일보다 늦지 않도록 조정
                      if (_endDate != null && _endDate!.isBefore(picked)) {
                        _endDate = picked;
                        _endDateController.text = picked.toIso8601String().split('T').first;
                      }
                    });
                  }
                },
              ),

              const SizedBox(height: 12),

              // 종료일
              TextField(
                controller: _endDateController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: '백테스팅 종료 날짜 설정',
                  suffixIcon: Icon(Icons.calendar_today),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _endDate ?? _startDate ?? DateTime.now(),
                    firstDate: _startDate ?? DateTime(2000),
                    lastDate: DateTime.now(),
                    builder: (context, child) {
                      final base = Theme.of(context);
                      return Theme(
                        data: base.copyWith(
                          dialogTheme: const DialogThemeData(
                            backgroundColor: Colors.white,
                          ),
                          colorScheme: const ColorScheme.light(
                            primary: Colors.black,
                            onPrimary: Colors.white,
                            surface: Colors.white,
                            onSurface: Colors.black,
                          ),
                          datePickerTheme: const DatePickerThemeData(
                            backgroundColor: Colors.white,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) {
                    setState(() {
                      _endDate = picked;
                      _endDateController.text = picked.toIso8601String().split('T').first;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // 목표 수익률
              TextField(
                controller: _profitController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: '백테스팅 수익률 설정',
                  hintText: '예: 12.5  →  12.5%',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 16),

              // 버튼들
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.black26),
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.white,
                      minimumSize: const Size(0, 40),
                    ),
                    child: const Text('취소'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: (_selectedStockId != null && !_loading) ? _runBacktest : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 40),
                    ),
                    child: _loading
                        ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                        : const Text('백테스팅 진행'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12)),
    );
  }
}
