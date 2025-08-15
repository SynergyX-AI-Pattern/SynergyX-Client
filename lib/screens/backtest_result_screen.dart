import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:interactive_chart/interactive_chart.dart';
import 'package:stockapp/data/candle_api.dart';

class BacktestResultScreen extends StatefulWidget {
  final Map<String, dynamic> result;

  const BacktestResultScreen({super.key, required this.result});

  @override
  State<BacktestResultScreen> createState() => _BacktestResultScreen();
}

class _BacktestResultScreen extends State<BacktestResultScreen> {
  List<CandleData> _candles = [];
  bool _candleLoading = false;

  @override
  void initState() {
    final root = widget.result;
    final result = root['result'] ?? root;
    print('🔎 result keys: ${result.keys}');
    print('🔎 stockId candidates: '
        'result.stockId=${result['stockId']} '
        'root.stockId=${root['stockId']} '
        'result.stock?.id=${result['stock']?['id']}');
    print('🔎 equityCurve len: ${(result['equityCurve'] as List?)?.length}');

    super.initState();
    print('📊 BacktestResultScreen result: ${widget.result}');
    _loadCandles();
  }

  Future<void> _loadCandles() async {
    // 서버 응답은 { isSuccess, code, result: {...} } 형태일 수도 있어서 유연하게 처리
    final root = widget.result;
    final result = root['result'] ?? root;

    // 여러 경로에서 stockId/기간을 찾아봄 (ChartBacktestScreen에서 주입해줬다면 root에도 있을 수 있음)
    final dynamic stockIdDyn =
        result['stockId'] ?? root['stockId'] ?? result['stock']?['id'];
    final String? startStr = (result['startDate'] ?? root['startDate'])?.toString();
    final String? endStr   = (result['endDate']   ?? root['endDate'])?.toString();

    debugPrint('🔎 _loadCandles() stockId=$stockIdDyn, start=$startStr, end=$endStr');

    // 필수 파라미터 확인
    if (stockIdDyn == null) {
      debugPrint('❗ stockId가 없어 캔들 요청을 건너뜀. (ChartBacktestScreen에서 결과에 stockId를 같이 넘겨주세요)');
      setState(() {
        _candleLoading = false;
        _candles = [];
      });
      return;
    }
    if (startStr == null || endStr == null) {
      debugPrint('❗ 날짜(start/end)가 없어 캔들 요청을 건너뜀.');
      setState(() {
        _candleLoading = false;
        _candles = [];
      });
      return;
    }

    setState(() {
      _candleLoading = true;
      _candles = [];
    });

    try {
      // 종료일 포함 보정: 선택한 end 날짜의 23:59:59.999까지 포함
      final startDt = DateTime.parse(startStr);
      final endDt = DateTime.parse(endStr)
          .add(const Duration(days: 1))
          .subtract(const Duration(milliseconds: 1));
      final startMs = startDt.millisecondsSinceEpoch;
      final endMs = endDt.millisecondsSinceEpoch;

      final String stockId = stockIdDyn.toString();

      debugPrint('📥 candles fetch: stockId=$stockId, range=$startStr~$endStr (ms: $startMs~$endMs)');

      // 서버 캔들은 CandleApiResponse -> CandleData(timestamp: ms)로 이미 변환됨
      final data = await fetchCandles(stockId: stockId, interval: '5Y');
      debugPrint('📈 원본 캔들 수: ${data.length}');

      if (data.isEmpty) {
        setState(() {
          _candleLoading = false;
          _candles = [];
        });
        return;
      }

      // 정렬 보장
      data.sort((a, b) => a.timestamp.compareTo(b.timestamp));

      // 기간 필터 (밀리초 기준)
      final filtered = data
          .where((c) => c.timestamp >= startMs && c.timestamp <= endMs)
          .toList();
      debugPrint('🧪 필터 후 캔들 수: ${filtered.length}');

      // interactive_chart 제약: 최소 3개 필요
      List<CandleData> display;
      if (filtered.length >= 3) {
        display = filtered;
      } else {
        // 기간에 너무 적게 잡히면 최근 N개로 대체 노출 (차트가 깨지지 않도록)
        final int take = data.length >= 60 ? 60 : data.length;
        display = data.sublist(data.length - take);
        debugPrint('⚠️ 필터 결과가 3개 미만 → 최근 $take개로 대체 노출');
      }

      setState(() {
        _candles = display;
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

  @override
  Widget build(BuildContext context) {
    final result = widget.result['result'];
    final res = widget.result['result'] ?? widget.result;
    final stockName = res['stockName'] ?? widget.result['stockName'] ?? '-';
    final stockId   = res['stockId'] ?? widget.result['stockId'];

    print('📌 UI stockName=$stockName stockId=$stockId');
    print('📊 equityCurve: ${result['equityCurve']}');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('백테스트 결과'), backgroundColor: Colors.white),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 캔들 차트
              SizedBox(
                height: 200,
                child: _candleLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _candles.isEmpty
                    ? const Center(child: Text('캔들 데이터 없음'))
                    : InteractiveChart(
                  candles: _candles,
                  style: const ChartStyle(
                    priceGainColor: Color(0xFFDF1525),
                    priceLossColor: Color(0xFF1573FE),
                    priceLabelStyle: TextStyle(color: Colors.grey),
                    timeLabelStyle: TextStyle(color: Colors.grey),
                  ),
                ),
              ),

              // 텍스트 정보
              Text('📌 종목: $stockName (${stockId ?? "-"})'),
              const SizedBox(height: 8),
              Text('✅ 매칭 횟수: ${result['matchedCount']}회'),
              Text('🎯 승률: ${result['winRate']}%'),
              Text('📈 평균 수익률: ${result['averageReturn']}%'),
              Text('🏆 최대 수익률: ${result['maxReturn']}% (${result['maxReturnDate']})'),
              Text('📅 기간: ${result['startDate']} ~ ${result['endDate']}'),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );

  }
}
