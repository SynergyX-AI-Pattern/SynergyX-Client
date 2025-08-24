//pattern_applies

class PatternApplies {
  final int patternApplyId; // 패턴 적용 ID
  final int stockId; // 종목 ID
  final String stockName; // 종목 이름
  final String stockImage; // 종목 이미지 URL
  final PatternInfo? pattern; // 적용된 패턴 정보

  PatternApplies({
    required this.patternApplyId,
    required this.stockId,
    required this.stockName,
    required this.stockImage,
    required this.pattern,
  });

  factory PatternApplies.fromJson(Map<String, dynamic> json) {
    final r = json['result'] as Map<String, dynamic>;
    final stock = r['stock'] as Map<String, dynamic>;
    final patt = r['pattern'] as Map<String, dynamic>?;

    return PatternApplies(
      patternApplyId: (r['patternApplyId'] as num?)?.toInt() ?? 0,
      stockId: stock['stockId'] as int,
      stockName: stock['stockName'] as String,
      stockImage: stock['stockImage'] as String? ?? '',
      pattern: patt == null ? null : PatternInfo.fromJson(patt),
    );
  }

  bool get hasPattern => pattern != null && pattern!.points.isNotEmpty;
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

  factory PatternInfo.fromJson(Map<String, dynamic> json) =>
      PatternInfo(
        patternId: json['patternId'] as int,
        points: (json['points'] as List).map((e) => e as num).toList(),
        tolerance: (json['tolerance'] as num).toDouble(),
        periodValue: json['periodValue'].toString(),
        periodUnit: json['periodUnit'].toString(),
      );
}