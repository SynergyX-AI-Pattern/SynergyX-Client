import 'package:flutter/material.dart';
import 'package:interactive_chart/interactive_chart.dart';
import 'package:stockapp/data/candle_api.dart';
import 'package:stockapp/data/pattern_api.dart';
import 'dart:math' as math;

class BacktestResultScreen extends StatefulWidget {
  final Map<String, dynamic> result;

  const BacktestResultScreen({super.key, required this.result});

  @override
  State<BacktestResultScreen> createState() => _BacktestResultScreenState();
}

class _BacktestResultScreenState extends State<BacktestResultScreen> {
  List<CandleData> _candles = [];
  bool _candleLoading = false;
  List<int> _patternPoints = [];
  int? _matchStart;
  int? _matchEnd;

  Map<String, dynamic> get _res {
    final root = widget.result;
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
    return s.split('T').first; // ISO 형태면 'T' 앞부분만 사용
  }

  @override
  void initState() {
    super.initState();
    final res = _res;
    _matchStart = _asNum<int>(res['matchStartIndex'] ?? res['matchStart'] ?? res['startIndex']);
    _matchEnd = _asNum<int>(res['matchEndIndex'] ?? res['matchEnd'] ?? res['endIndex']);
    _loadCandles();
    _loadPatternPoints();
  }


  Future<void> _loadCandles() async {
    final res = _res;

    final dynamic stockIdDyn =
        res['stockId'] ?? widget.result['stockId'] ?? (res['stock'] is Map ? (res['stock'] as Map)['id'] : null);
    final String? stockId =
    (stockIdDyn == null) ? null : stockIdDyn.toString();

    if (stockId == null) {
      debugPrint('⚠️ stockId가 없어 캔들 요청을 생략합니다.');
      return;
    }

    setState(() => _candleLoading = true);
    try {
      final candles = await fetchCandles(stockId: stockId, interval: '1D');
      setState(() {
        _candles = candles;
        _candleLoading = false;
      });
    } catch (e) {
      debugPrint('⚠️ 캔들 로딩 실패: $e');
      setState(() {
        _candleLoading = false;
        _candles = [];
      });
    }
  }

  Future<void> _loadPatternPoints() async {
    final res = _res;
    final pid = _asNum<int>(res['patternId'] ?? widget.result['patternId']);
    if (pid == null) return;
    try {
      final detail = await PatternApi.getPatternDetail(pid);
      setState(() {
        _patternPoints = detail.points;
      });
    } catch (e) {
      debugPrint('⚠️ 패턴 로딩 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final res = _res; // 정규화된 결과
    final stockName = (res['stockName'] ?? widget.result['stockName'] ?? '-').toString();

    final String? startDate = res['startDate']?.toString() ?? widget.result['startDate']?.toString();
    final String? endDate   = res['endDate']?.toString()   ?? widget.result['endDate']?.toString();

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
                  backgroundImage: NetworkImage(res["stockImage"] ?? ""),
                  backgroundColor: Colors.grey.shade200,
                ),
                const SizedBox(width: 12),
                Text(
                  stockName,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 차트 카드 영역
            SizedBox(
              height: 200,
              child: _candleLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _candles.isEmpty
                  ? const Center(child: Text('캔들 데이터 없음'))
                  : Stack(
                children: [
                  InteractiveChart(
                    candles: _candles,
                    style: const ChartStyle(
                      priceGainColor: Color(0xFFDF1525),
                      priceLossColor: Color(0xFF1573FE),
                    ),
                  ),
                  if (_matchStart != null &&
                      _matchEnd != null &&
                      _patternPoints.isNotEmpty)
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _MatchOverlayPainter(
                          start: _matchStart!,
                          end: _matchEnd!,
                          total: _candles.length,
                          patternPoints: _patternPoints,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
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
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            const Text("승률", style: TextStyle(color: Colors.grey)),
                            const SizedBox(height: 4),
                            Text(_fmtPercent(res['winRate']),
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            const Text("평균 수익률", style: TextStyle(color: Colors.grey)),
                            const SizedBox(height: 4),
                            Text(_fmtPercent(res['averageReturn']),
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF289BF6))),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            const Text("최대 수익률", style: TextStyle(color: Colors.grey)),
                            const SizedBox(height: 4),
                            Text(_fmtPercent(res['maxReturn']),
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF289BF6))),
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
                            const Text("최대 손실률", style: TextStyle(color: Colors.grey)),
                            const SizedBox(height: 4),
                            Text(_fmtPercent(res['maxLoss']),
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold, color: Colors.red)),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            const Text("누적 수익률", style: TextStyle(color: Colors.grey)),
                            const SizedBox(height: 4),
                            Text(_fmtPercent(res['cumulativeReturn']),
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF289BF6))),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            const Text("마지막 수익률", style: TextStyle(color: Colors.grey)),
                            const SizedBox(height: 4),
                            Text(_fmtPercent(res['lastReturn']),
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF289BF6))),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text("마지막 매칭일: ${res["lastMatchDate"] ?? "-"}",
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

/// 캔들 차트 위에 매칭된 구간과 패턴을 그리는 페인터
class _MatchOverlayPainter extends CustomPainter {
  final int start;              // 매칭 시작 인덱스
  final int end;                // 매칭 종료 인덱스
  final int total;              // 전체 캔들 수
  final List<int> patternPoints; // 패턴을 그리기 위한 점 목록

  _MatchOverlayPainter({
    required this.start,
    required this.end,
    required this.total,
    required this.patternPoints,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (total <= 0 || end < start) return;

    final candleWidth = size.width / total;
    final rect = Rect.fromLTWH(
      start * candleWidth,
      0,
      (end - start + 1) * candleWidth,
      size.height,
    );

    // 매칭 영역 음영 처리
    final fill = Paint()
      ..color = Colors.amber.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;
    canvas.drawRect(rect, fill);

    // 테두리
    final border = Paint()
      ..color = Colors.amber
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRect(rect, border);

    // 패턴 모양 그리기
    if (patternPoints.length >= 2) {
      final minY = patternPoints.reduce(math.min).toDouble();
      final maxY = patternPoints.reduce(math.max).toDouble();
      final diffY = (maxY - minY == 0) ? 1 : maxY - minY;

      final path = Path();
      for (int i = 0; i < patternPoints.length; i++) {
        final x = rect.left + (i / (patternPoints.length - 1)) * rect.width;
        final normY = (patternPoints[i] - minY) / diffY;
        final y = rect.bottom - normY * rect.height;
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }

      final line = Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawPath(path, line);
    }
  }

  @override
  bool shouldRepaint(covariant _MatchOverlayPainter oldDelegate) {
    return start != oldDelegate.start ||
        end != oldDelegate.end ||
        total != oldDelegate.total ||
        patternPoints != oldDelegate.patternPoints;
  }
}