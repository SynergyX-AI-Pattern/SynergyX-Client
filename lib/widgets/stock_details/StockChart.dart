import 'package:flutter/material.dart';
import 'package:interactive_chart/interactive_chart.dart';

import '../../data/candle_api.dart';

class CandlestickChart extends StatefulWidget {
  const CandlestickChart({super.key});

  @override
  State<CandlestickChart> createState() => _CandlestickChartState();
}

class _CandlestickChartState extends State<CandlestickChart> {
  final List<CandleData> _data = MockDataTesla.candles;
  bool _showAverage = false; // 이동 평균선

  @override
  Widget build(BuildContext context) {
    return Center(
          child: SafeArea(
            minimum: const EdgeInsets.all(24.0),
            child: InteractiveChart(
              candles: _data, //데이터
              // 차트 스타일
              style: ChartStyle(
                priceGainColor: Color(0xFFDF1525),   // 상승 → 빨강
                priceLossColor: Color(0xFF1573FE),
              //   volumeColor: Colors.teal.withOpacity(0.8),
              //   trendLineStyles: [
              //     Paint()
              //       ..strokeWidth = 2.0
              //       ..strokeCap = StrokeCap.round
              //       ..color = Colors.deepOrange,
              //     Paint()
              //       ..strokeWidth = 4.0
              //       ..strokeCap = StrokeCap.round
              //       ..color = Colors.orange,
              //   ],
              //   priceGridLineColor: Colors.blue[200]!,
              //   priceLabelStyle: TextStyle(color: Colors.blue[200]),
              //   timeLabelStyle: TextStyle(color: Colors.blue[200]),
              //   selectionHighlightColor: Colors.red.withOpacity(0.2),
                overlayBackgroundColor: Colors.black.withOpacity(0.6),
              //   overlayTextStyle: TextStyle(color: Colors.red[100]),
                // timeLabelHeight: 32,
              //   volumeHeightFactor: 0.2, // volume area is 20% of total height
              ),
              /** Customize axis labels */
              // timeLabel: (timestamp, visibleDataCount) => "📅",
              priceLabel: (price) => "${price.round()}",
              /** Customize overlay (tap and hold to see it)
               ** Or return an empty object to disable overlay info. */
              // 시간, 시가, 고가, 저가, 종가, 거래량 -> 한글로 변경
              overlayInfo: (candle) {
                final date = DateTime.fromMillisecondsSinceEpoch(candle.timestamp);
                final formattedDate = "${date.year}-${date.month}-${date.day}";
                final volumeMillion = (candle.volume ?? 0) / 1000000;

                return {
                  "날짜": formattedDate,
                  "시가": "${candle.open?.toStringAsFixed(2)}",
                  "고가": "${candle.high?.toStringAsFixed(2)}",
                  "저가": "${candle.low?.toStringAsFixed(2)}",
                  "종가": "${candle.close?.toStringAsFixed(2)}",
                  "거래량": "${volumeMillion.toStringAsFixed(3)}M",  // 예: 17.500M
                };
              },
              /** Callbacks */
              // onTap: (candle) => print("user tapped on $candle"),
              // onCandleResize: (width) => print("each candle is $width wide"),
            ),
          ),
        );
  }

// 이동 평균선
  _computeTrendLines() {
    final ma7 = CandleData.computeMA(_data, 7);
    final ma30 = CandleData.computeMA(_data, 30);
    final ma90 = CandleData.computeMA(_data, 90);

    for (int i = 0; i < _data.length; i++) {
      _data[i].trends = [ma7[i], ma30[i], ma90[i]];
    }
  }

  _removeTrendLines() {
    for (final data in _data) {
      data.trends = [];
    }
  }
}
