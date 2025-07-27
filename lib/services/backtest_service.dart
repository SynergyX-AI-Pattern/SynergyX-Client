class BacktestService {
  static Future<Map<String, dynamic>> run({
    required Map<String, dynamic> pattern,
    required String symbol,
    required String stockName,
  }) async {

    await Future.delayed(Duration(seconds: 2));

    return {
      'matchedCount': 12,
      'winRate': 66.7,
      'averageReturn': 3.45,
      'maxReturn': 12.3,
      'maxReturnDate': '2024-08-01',
      'startDate': '2024-01-01',
      'endDate': '2025-01-01',
      'symbol': symbol,
      'stockName': stockName,
    };
  }
}
