import 'package:interactive_chart/interactive_chart.dart';

class CandleApiResponse {
  final String time;
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;

  CandleApiResponse({
    required this.time,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });

  factory CandleApiResponse.fromJson(Map<String, dynamic> json) {
    return CandleApiResponse(
      time: json['time'],
      open: json['open'].toDouble(),
      high: json['high'].toDouble(),
      low: json['low'].toDouble(),
      close: json['close'].toDouble(),
      volume: json['volume'].toDouble(),
    );
  }

  CandleData toCandleData() {
    return CandleData(
      timestamp: DateTime.parse(time).millisecondsSinceEpoch,
      open: open,
      high: high,
      low: low,
      close: close,
      volume: volume,
    );
  }
}
