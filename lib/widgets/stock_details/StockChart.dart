import 'package:flutter/material.dart';
import 'package:interactive_chart/interactive_chart.dart';
import '../../data/candle_api.dart';

class CandlestickChart extends StatefulWidget {
  final String stockId;

  const CandlestickChart({
    super.key,
    required this.stockId,
  });

  @override
  State<CandlestickChart> createState() => _CandlestickChartState();
}

class _CandlestickChartState extends State<CandlestickChart> {
  List<CandleData> _candles = [];
  bool _loading = true;

  String _selectedInterval = '1M'; // 기본 interval

  final Map<String, String> intervalLabels = {
    '1D': '1D',
    '1W': '1W',
    '1M': '1M',
    '1Y': '1Y',
    '5Y': '5Y',
  };

  @override
  void initState() {
    super.initState();
    _loadCandles();
  }

  Future<void> _loadCandles() async {
    setState(() {
      _loading = true;
    });

    try {
      final data = await fetchCandles(
        stockId: widget.stockId,
        interval: _selectedInterval,
      );
      setState(() {
        _candles = data;
        _loading = false;
      });
    } catch (e) {
      print("❌ Candle API error: $e");
      setState(() {
        _loading = false;
      });
    }
  }

  Widget _buildIntervalSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: intervalLabels.entries.map((entry) {
        final isSelected = entry.key == _selectedInterval;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedInterval = entry.key;
            });
            _loadCandles();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected ? Color(0xFFFFE5E5) : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              entry.value,
              style: TextStyle(
                color: isSelected ? Color(0xFFDF1525) : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontFamily: 'Pretendard',
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        _buildIntervalSelector(),
        const SizedBox(height: 8),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _candles.isEmpty
              ? const Center(child: Text("데이터 없음"))
              : SafeArea(
            minimum: const EdgeInsets.all(16),
            child: InteractiveChart(
              candles: _candles,
              style: ChartStyle(
                priceGainColor: Color(0xFFDF1525),
                priceLossColor: Color(0xFF1573FE),
                priceLabelStyle: TextStyle(color: Colors.grey),
                timeLabelStyle: TextStyle(color: Colors.grey),
                overlayBackgroundColor:
                Colors.black.withOpacity(0.6),
                overlayTextStyle: TextStyle(color: Colors.white),
              ),
              priceLabel: (price) => "${price.round()}",
              overlayInfo: (candle) {
                final date = DateTime.fromMillisecondsSinceEpoch(
                    candle.timestamp);
                final formattedDate =
                    "${date.year}-${date.month}-${date.day}";
                final volumeMillion =
                    (candle.volume ?? 0) / 1000000;
                return {
                  "날짜": formattedDate,
                  "시가": "${candle.open?.toStringAsFixed(2)}",
                  "고가": "${candle.high?.toStringAsFixed(2)}",
                  "저가": "${candle.low?.toStringAsFixed(2)}",
                  "종가": "${candle.close?.toStringAsFixed(2)}",
                  "거래량": "${volumeMillion.toStringAsFixed(3)}M",
                };
              },
            ),
          ),
        ),
      ],
    );
  }
}
