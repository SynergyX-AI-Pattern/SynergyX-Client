import 'package:interactive_chart/interactive_chart.dart';

class MockDataTesla {
  static const List<dynamic> _rawData = [
    // (Price data for Tesla Inc, taken from Yahoo Finance)
    // timestamp, open, high, low, close, volume
    // 시간, 시가, 고가, 저가, 종가, 거래량
    [1633354200, 51000, 51500, 50500, 51200, 850000],
    [1633440600, 51400, 52000, 50800, 51600, 18432600],
    [1633527000, 51200, 51900, 51000, 51550, 14632800],
    [1633613400, 51800, 53200, 51700, 52800, 19195800],
    [1633699800, 52800, 52850, 51800, 52200, 16711100],
    [1633959000, 52100, 53000, 52000, 52600, 14175800],
    [1634064472, 52900, 53600, 52500, 53450, 17289281],
    [1634150872, 53500, 54000, 53000, 53800, 16500000],
    [1634237272, 53800, 55000, 53600, 54800, 17800000],
    [1634323672, 54800, 55500, 54500, 55300, 18200000],
    [1634410072, 55300, 55800, 55000, 55100, 16000000],
    [1634496472, 55100, 55600, 54900, 55550, 17500000],
  ];

  static List<CandleData> get candles => _rawData
      .map((row) => CandleData(
    timestamp: row[0] * 1000, //timestamp 초단위 * 1000 = 밀리초
    open: row[1]?.toDouble(),
    high: row[2]?.toDouble(),
    low: row[3]?.toDouble(),
    close: row[4]?.toDouble(),
    volume: row[5]?.toDouble(),
  ))
      .toList();
}