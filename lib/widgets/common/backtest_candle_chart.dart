import 'package:flutter/material.dart';
import 'package:interactive_chart/interactive_chart.dart';
import 'package:stockapp/data/backtest_candle_api.dart';
import 'package:stockapp/data/backtest_api.dart';

class BacktestCandleChart extends StatefulWidget {
  final int backtestId;
  const BacktestCandleChart({super.key, required this.backtestId});

  @override
  State<BacktestCandleChart> createState() => _BacktestCandleChartState();
}

class _BacktestCandleChartState extends State<BacktestCandleChart> {
  List<CandleData> _candles = [];
  bool _loading = false;

  int? _matchStart;
  int? _matchEnd;

  @override
  void initState() {
    super.initState();
    _loadCandlesAndHighlight();
  }

  /// 백테스트 캔들과 하이라이트 범위 불러오기
  Future<void> _loadCandlesAndHighlight() async {
    setState(() => _loading = true);

    try {
      // 1️⃣ 백테스트 상세 불러오기
      final detail = await BacktestService.fetchBacktestResult(widget.backtestId);
      final result = detail['result'] ?? detail;
      final hr = result['highlightRange'];
      debugPrint('✅ highlightRange: $hr');

      // 2️⃣ 캔들 데이터 불러오기
      final candles = await fetchBacktestCandles(backtestId: widget.backtestId);
      if (candles.isEmpty) {
        debugPrint('⚠️ 캔들 데이터 없음');
        setState(() {
          _candles = [];
          _loading = false;
        });
        return;
      }

      // 3️⃣ highlightRange가 존재할 경우 인덱스 계산
      int? startIdx;
      int? endIdx;

      if (hr is Map && hr['fromDate'] != null && hr['toDate'] != null) {
        final fromDate = DateTime.tryParse(hr['fromDate'].toString());
        final toDate = DateTime.tryParse(hr['toDate'].toString());
        if (fromDate != null && toDate != null) {
          // 시간대 보정 (서버 UTC 가정)
          final from = fromDate.toUtc();
          final to = toDate.toUtc();

          // 캔들 타임스탬프 비교
          for (int i = 0; i < candles.length; i++) {
            final t = DateTime.fromMillisecondsSinceEpoch(candles[i].timestamp).toUtc();
            if (!t.isBefore(from)) {
              startIdx = i;
              break;
            }
          }

          if (startIdx != null) {
            for (int i = startIdx; i < candles.length; i++) {
              final t = DateTime.fromMillisecondsSinceEpoch(candles[i].timestamp).toUtc();
              if (t.isAfter(to)) {
                endIdx = i - 1;
                break;
              }
            }
            endIdx ??= candles.length - 1;
          }
        }
      }

      setState(() {
        _candles = candles;
        _matchStart = startIdx;
        _matchEnd = endIdx;
        _loading = false;
      });

      debugPrint('🎯 highlight index: $_matchStart ~ $_matchEnd');

    } catch (e, st) {
      debugPrint('❌ 캔들/하이라이트 로딩 실패: $e\n$st');
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)],
      ),
      clipBehavior: Clip.none,
      child: _loading
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
          // 🟨 노란색 하이라이트
          if (_matchStart != null &&
              _matchEnd != null &&
              _matchEnd! >= _matchStart!)
            Positioned.fill(
              child: CustomPaint(
                painter: _MatchOverlayPainter(
                  start: _matchStart!,
                  end: _matchEnd!,
                  total: _candles.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// 노란색 하이라이트 페인터
class _MatchOverlayPainter extends CustomPainter {
  final int start;
  final int end;
  final int total;

  _MatchOverlayPainter({
    required this.start,
    required this.end,
    required this.total,
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

    // 🟨 노란색 배경
    final fill = Paint()
      ..color = Colors.amber.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;
    canvas.drawRect(rect, fill);

    // 🟨 노란색 테두리
    final border = Paint()
      ..color = Colors.amber
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRect(rect, border);
  }

  @override
  bool shouldRepaint(covariant _MatchOverlayPainter old) {
    return start != old.start || end != old.end || total != old.total;
  }
}
