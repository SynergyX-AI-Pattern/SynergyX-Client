// backtest_result_screen.dart
import 'package:flutter/material.dart';

import 'package:stockapp/widgets/backtest/backtest_result_chart.dart';

/// 백테스트 결과 상세 화면
class BacktestResultScreen extends StatefulWidget {
  final Map<String, dynamic> result;
  const BacktestResultScreen({super.key, required this.result});

  @override
  State<BacktestResultScreen> createState() => _BacktestResultScreenState();
}

class _BacktestResultScreenState extends State<BacktestResultScreen> {
  Map<String, dynamic>? _detail;

  Map<String, dynamic> get _res {
    final root = _detail ?? widget.result;
    final r = root['result'];
    return (r is Map) ? Map<String, dynamic>.from(r) : root;
  }

  T? _asNum<T extends num>(dynamic v) {
    if (v is T) return v;
    if (v is num) return (T == int) ? v.toInt() as T : v.toDouble() as T;
    if (v is String) {
      final n = num.tryParse(v);
      if (n == null) return null;
      return (T == int) ? n.toInt() as T : n.toDouble() as T;
    }
    return null;
  }

  String _fmtPercent(dynamic v, {int fraction = 2}) {
    final n = _asNum<double>(v) ?? 0.0;
    return '${n.toStringAsFixed(fraction)}%';
  }

  String _fmtDate(String? s) {
    if (s == null || s.isEmpty) return '-';
    return s.split('T').first;
  }

  /// 차트가 상세 데이터를 받아오면 화면 전체에 반영한다.
  void _handleDetailLoaded(Map<String, dynamic> detail) {
    setState(() {
      _detail = detail;
    });
  }

  @override
  Widget build(BuildContext context) {
    final res = _res;

    final stockName =
    (res['stockName'] ??
        (res['stock'] is Map ? res['stock']['name'] : null) ??
        widget.result['stockName'] ??
        '-')
        .toString();

    final String? startDate =
        res['startDate']?.toString() ?? widget.result['startDate']?.toString();
    final String? endDate =
        res['endDate']?.toString() ?? widget.result['endDate']?.toString();

    final double? target = _asNum<double>(widget.result['targetReturn']);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('백테스팅 결과', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('실행일: ${res["executedAt"] ?? "-"}',
                    style: const TextStyle(color: Colors.grey)),
                const Spacer(),
                Text('매칭 횟수: ${res["matchedCount"] ?? "-"}',
                    style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: (res["stockImage"] != null &&
                      (res["stockImage"] as String).isNotEmpty)
                      ? NetworkImage(res["stockImage"])
                      : null,
                  child: (res["stockImage"] == null ||
                      (res["stockImage"] as String).isEmpty)
                      ? const Icon(Icons.image_not_supported,
                      color: Colors.grey, size: 18)
                      : null,
                ),
                const SizedBox(width: 12),
                Text(
                  stockName,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 차트 카드 영역
            SizedBox(
              height: 200,
              child: BacktestHighlightChart(
                summary: widget.result,
                onDetailLoaded: _handleDetailLoaded,
              ),
            ),
            const SizedBox(height: 16),

            Container(
              width: double.infinity,
              padding:
              const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 4)
                ],
              ),
              child: Row(
                children: [
                  Text('기간: ${_fmtDate(startDate)} ~ ${_fmtDate(endDate)}'),
                  const Spacer(),
                  if (target != null) Text('수익률: ${target.toStringAsFixed(2)}%'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 4)
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            const Text("승률",
                                style: TextStyle(color: Colors.grey)),
                            const SizedBox(height: 4),
                            Text(_fmtPercent(res['winRate']),
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black)),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            const Text("평균 수익률",
                                style: TextStyle(color: Colors.grey)),
                            const SizedBox(height: 4),
                            Text(_fmtPercent(res['averageReturn']),
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF289BF6))),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            const Text("최대 수익률",
                                style: TextStyle(color: Colors.grey)),
                            const SizedBox(height: 4),
                            Text(_fmtPercent(res['maxReturn']),
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF289BF6))),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            const Text("최대 손실률",
                                style: TextStyle(color: Colors.grey)),
                            const SizedBox(height: 4),
                            Text(
                                _fmtPercent(
                                    res['maxLoss'] ?? res['minReturn']),
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red)),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            const Text("누적 수익률",
                                style: TextStyle(color: Colors.grey)),
                            const SizedBox(height: 4),
                            Text(
                                _fmtPercent(res['cumulativeReturn'] ??
                                    res['totalReturn']),
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF289BF6))),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            const Text("마지막 수익률",
                                style: TextStyle(color: Colors.grey)),
                            const SizedBox(height: 4),
                            Text(
                                _fmtPercent(res['lastReturn'] ??
                                    res['lastMatchedReturn']),
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF289BF6))),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                      "마지막 매칭일: ${res["lastMatchDate"] ?? res["lastMatchedDate"] ?? "-"}",
                      style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}