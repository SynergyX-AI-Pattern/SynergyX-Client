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
    super.initState();
    print('📊 BacktestResultScreen result: ${widget.result}');
    _loadCandles();
  }

  Future<void> _loadCandles() async {
    final result = widget.result['result'];

    final stockId = result['stockId'];
    if (stockId == null) return;

    setState(() {
      _candleLoading = true;
      _candles = [];
    });

    try {
      final start = DateTime.parse(result['startDate']).millisecondsSinceEpoch;
      final end = DateTime.parse(result['endDate']).millisecondsSinceEpoch;

      print('📥 stockId: $stockId');
      print('📅 기간: $start ~ $end');

      final data = await fetchCandles(stockId: stockId.toString(), interval: '5Y');
      print('📈 가져온 캔들 수: ${data.length}');

      final filtered = data.where((c) => c.timestamp >= start && c.timestamp <= end).toList();
      print('🧪 필터링 후 캔들 수: ${filtered.length}');

      setState(() {
        _candles = filtered;
        _candleLoading = false;
      });
    } catch (e) {
      print('⚠️ 캔들 로딩 실패: $e');
    }

  }

  @override
  Widget build(BuildContext context) {
    final result = widget.result['result'];
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
              // 수익률 차트
              SizedBox(
                height: 200,
                child: _buildResultChart(result['equityCurve'] as List<dynamic>?),
              ),
              const SizedBox(height: 24),

              // 텍스트 정보
              Text('📌 종목: ${result['stockName']} (${result['stockId']})'),
              const SizedBox(height: 8),
              Text('✅ 매칭 횟수: ${result['matchedCount']}회'),
              Text('🎯 승률: ${result['winRate']}%'),
              Text('📈 평균 수익률: ${result['averageReturn']}%'),
              Text('🏆 최대 수익률: ${result['maxReturn']}% (${result['maxReturnDate']})'),
              Text('📅 기간: ${result['startDate']} ~ ${result['endDate']}'),

              const SizedBox(height: 16),
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
            ],
          ),
        ),
      ),
    );

  }

  /// 수익률 차트 (LineChart)
  Widget _buildResultChart(List<dynamic>? curve) {
    if (curve == null || curve.isEmpty) {
      return const Center(child: Text('차트 데이터 없음'));
    }

    final spots = <FlSpot>[
      for (int i = 0; i < curve.length; i++)
        FlSpot(i.toDouble(), (curve[i]['value'] as num).toDouble()),
    ];

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
}
