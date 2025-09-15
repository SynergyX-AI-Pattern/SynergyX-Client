// backtest_result_screen.dart
import 'package:flutter/material.dart';
import 'package:interactive_chart/interactive_chart.dart';
import 'package:stockapp/data/backtest_candle_api.dart';

import 'package:stockapp/data/backtest_api.dart';
import 'dart:math' as math;

/// 백테스트 결과 상세 화면
class BacktestResultScreen extends StatefulWidget {
  final Map<String, dynamic> result;
  const BacktestResultScreen({super.key, required this.result});

  @override
  State<BacktestResultScreen> createState() => _BacktestResultScreenState();
}

class _BacktestResultScreenState extends State<BacktestResultScreen> {
  Map<String, dynamic>? _detail;

  List<CandleData> _candles = [];
  bool _candleLoading = false;

  List<int> _patternPoints = [];
  int? _matchStart;
  int? _matchEnd;
  DateTime? _hlFrom;
  DateTime? _hlTo;


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

  DateTime? _parseDate(dynamic s) {
    if (s == null) return null;
    final str = s.toString();
    if (str.isEmpty) return null;
    return DateTime.tryParse(str);
  }

  // 하이라이트 적용
  void _applyBestMatch(Map<String, dynamic> data) {
    final hr = data['highlightRange'];
    final hasHR = hr is Map && (hr['fromDate'] != null && hr['toDate'] != null);


    List<int> pts = [];
    final dynamic matchesRaw = data['matches'] ?? data['matchResults'];
    if (matchesRaw is List && matchesRaw.isNotEmpty) {
      Map<String, dynamic> best = Map<String, dynamic>.from(matchesRaw.first as Map);
      double bestReturn = _asNum<double>(
        best['return'] ?? best['profit'] ?? best['returnRate'] ?? best['rate'],
      ) ??
          0;

      for (final m in matchesRaw.skip(1)) {
        final r = _asNum<double>(m['return'] ?? m['profit'] ?? m['returnRate'] ?? m['rate']) ?? 0;
        if (r > bestReturn) {
          best = Map<String, dynamic>.from(m as Map);
          bestReturn = r;
        }
      }
      final dynamic pp = best['patternPoints'] ?? best['points'];
      if (pp is List) {
        pts = pp.map((e) => _asNum<int>(e) ?? 0).toList();
      }

      if (!hasHR) {
        final s = _asNum<int>(best['startIndex'] ?? best['matchStartIndex'] ?? best['start']);
        final e = _asNum<int>(best['endIndex'] ?? best['matchEndIndex'] ?? best['end']);
        setState(() {
          _patternPoints = pts;
          _matchStart = s;
          _matchEnd = e;
          _hlFrom = null;
          _hlTo = null;
        });
        return;
      }
    }

    if (hasHR) {
      setState(() {
        _hlFrom = _parseDate(hr['fromDate']);
        _hlTo   = _parseDate(hr['toDate']);
        _patternPoints = pts;
        _matchStart = null;
        _matchEnd   = null;
      });
      return;
    }

    final s = _asNum<int>(data['startIndex'] ?? data['matchStartIndex'] ?? data['matchStart']);
    final e = _asNum<int>(data['endIndex']   ?? data['matchEndIndex']   ?? data['matchEnd']);
    setState(() {
      _patternPoints = pts;
      _matchStart = s;
      _matchEnd = e;
      _hlFrom = null;
      _hlTo = null;
    });
  }

  void _applyHighlightFromDates() {
    if (_hlFrom == null || _hlTo == null || _candles.isEmpty) return;

    final from = _hlFrom!.toLocal();
    final to   = _hlTo!.toLocal();

    int? startIdx;
    for (int i = 0; i < _candles.length; i++) {
      final t = DateTime.fromMillisecondsSinceEpoch(_candles[i].timestamp).toLocal();
      if (!t.isBefore(from)) { startIdx = i; break; }
    }
    if (startIdx == null) return;

    int endIdx = _candles.length - 1;
    for (int i = startIdx; i < _candles.length; i++) {
      final t = DateTime.fromMillisecondsSinceEpoch(_candles[i].timestamp).toLocal();
      if (t.isAfter(to)) { endIdx = i - 1; break; }
    }
    if (endIdx < startIdx) return;

    setState(() { _matchStart = startIdx; _matchEnd = endIdx; });
  }

  @override
  void initState() {
    super.initState();
    _applyBestMatch(_res);
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    final id = _asNum<int>(_res['backtestId'] ?? widget.result['backtestId']);
    if (id == null) return;

    try {
      final stockId = _asNum<int>(_res['stockId'] ?? widget.result['stockId']);
      final fetched = await BacktestService.fetchBacktestResult(
        id,
        stockId: stockId,
      );

      setState(() {
        _detail = fetched;
      });

      _applyBestMatch(fetched);


      await _loadCandles();
    } catch (e) {
      debugPrint('⚠️ 상세 로딩 실패: $e');
    }
  }

  Future<void> _loadCandles() async {
    final res = _res;

    final int? backtestId =
    _asNum<int>(res['backtestId'] ?? widget.result['backtestId']);

    if (backtestId == null) {
      debugPrint('⚠️ backtestId가 없어 캔들 요청을 생략합니다.');
      return;
    }

    setState(() => _candleLoading = true);
    try {
      // margin 기본값(20)으로 백테스트 캔들을 조회한다.
      final candles = await fetchBacktestCandles(
        backtestId: backtestId,
      );

      setState(() {
        _candles = candles;
        _candleLoading = false;
      });

      _applyHighlightFromDates();

    } catch (e) {
      setState(() {
        _candleLoading = false;
        _candles = [];
      });
    }
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
                      _matchEnd! >= _matchStart!)
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

/// 매칭 구간/패턴 오버레이 페인터
class _MatchOverlayPainter extends CustomPainter {
  final int start;
  final int end;
  final int total;
  final List<int> patternPoints;

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

    // 매칭 영역 음영
    final fill = Paint()
      ..color = Colors.amber.withValues(alpha:0.2)

      ..style = PaintingStyle.fill;
    canvas.drawRect(rect, fill);

    // 테두리
    final border = Paint()
      ..color = Colors.amber
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRect(rect, border);

    // 패턴 모양(선) — 서버가 제공한 경우에만
    if (patternPoints.length >= 2) {
      final minY = patternPoints.reduce(math.min).toDouble();
      final maxY = patternPoints.reduce(math.max).toDouble();
      final diffY = (maxY - minY == 0) ? 1 : maxY - minY;

      final path = Path();
      for (int i = 0; i < patternPoints.length; i++) {
        final x =
            rect.left + (i / (patternPoints.length - 1)) * rect.width;
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
  bool shouldRepaint(covariant _MatchOverlayPainter old) {
    return start != old.start ||
        end != old.end ||
        total != old.total ||
        patternPoints != old.patternPoints;
  }
}
