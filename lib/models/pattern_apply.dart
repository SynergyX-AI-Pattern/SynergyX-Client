class PatternApply {
  final int stockId;
  final String stockName;
  final String stockImage;
  final PatternInfo? pattern;
  final BacktestResult? backtest;

  final int? patternApplyId;
  final bool? isAlertEnabled;

  PatternApply({
    required this.stockId,
    required this.stockName,
    required this.stockImage,
    required this.pattern,
    required this.backtest,

    this.patternApplyId,
    this.isAlertEnabled,
  });

  factory PatternApply.fromJson(Map<String, dynamic> json) {
    final r = json['result'] as Map<String, dynamic>;
    final stock = r['stock'] as Map<String, dynamic>;
    final patt = r['pattern'] as Map<String, dynamic>?;
    final bt   = r['backtestResult'] as Map<String, dynamic>?;

    return PatternApply(
      stockId: stock['stockId'] as int,
      stockName: stock['stockName'] as String,
      stockImage: stock['stockImage'] as String? ?? '',
      pattern: patt == null ? null : PatternInfo.fromJson(patt),
      backtest: bt == null ? null : BacktestResult.fromJson(bt),

      patternApplyId: r['patternApplyId'] as int?,
      isAlertEnabled: r['isAlertEnabled'] as bool?,
    );
  }

  bool get hasPattern  => pattern  != null && pattern!.points.isNotEmpty;
  bool get hasBacktest => backtest != null;
}

class PatternInfo {
  final int patternId;
  final List<num> points;
  final double tolerance;
  final String periodValue;
  final String periodUnit;

  PatternInfo({
    required this.patternId,
    required this.points,
    required this.tolerance,
    required this.periodValue,
    required this.periodUnit,
  });

  factory PatternInfo.fromJson(Map<String, dynamic> json) => PatternInfo(
    patternId: json['patternId'] as int,
    points: (json['points'] as List).map((e) => e as num).toList(),
    tolerance: (json['tolerance'] as num).toDouble(),
    periodValue: json['periodValue'].toString(),
    periodUnit: json['periodUnit'].toString(),
  );
}

// ★ 백테스트 결과 모델 추가
class BacktestResult {
  final int backtestId;
  final String executedAt;   // '2025-08-16'
  final String startDate;    // '2025-07-01'
  final String endDate;      // '2025-08-13'
  final int matchedCount;    // 5
  final num winRate;         // 20  (단위: %)
  final double averageReturn; // 0.05342... (단위: 비율)
  final double maxReturn;     // 1.92 (단위: % 인지 리턴값 인지 백엔드 정의에 따름)
  final String maxReturnDate; // '2025-07-14'

  BacktestResult({
    required this.backtestId,
    required this.executedAt,
    required this.startDate,
    required this.endDate,
    required this.matchedCount,
    required this.winRate,
    required this.averageReturn,
    required this.maxReturn,
    required this.maxReturnDate,
  });

  factory BacktestResult.fromJson(Map<String, dynamic> json) => BacktestResult(
    backtestId: json['backtestId'] as int,
    executedAt: json['executedAt'] as String,
    startDate: json['startDate'] as String,
    endDate: json['endDate'] as String,
    matchedCount: json['matchedCount'] as int,
    winRate: json['winRate'] as num,
    averageReturn: (json['averageReturn'] as num).toDouble(),
    maxReturn: (json['maxReturn'] as num).toDouble(),
    maxReturnDate: json['maxReturnDate'] as String,
  );
}
