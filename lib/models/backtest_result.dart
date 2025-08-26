/// 백테스트 결과 모델
class BacktestResult {
  final int? backtestId;
  final int? stockId;
  final String stockName;
  final String stockImage;
  final String executedAt;
  final String startDate;
  final String endDate;
  final int matchedCount;
  final double winRate;
  final double averageReturn;
  final double maxReturn;
  final String maxReturnDate;
  final double minReturn;
  final String minReturnDate;
  final double totalReturn;
  final String lastMatchedDate;
  final double lastMatchedReturn;
  final double? targetReturn;

  BacktestResult({
    this.backtestId,
    this.stockId,
    required this.stockName,
    required this.stockImage,
    required this.executedAt,
    required this.startDate,
    required this.endDate,
    required this.matchedCount,
    required this.winRate,
    required this.averageReturn,
    required this.maxReturn,
    required this.maxReturnDate,
    required this.minReturn,
    required this.minReturnDate,
    required this.totalReturn,
    required this.lastMatchedDate,
    required this.lastMatchedReturn,
    this.targetReturn,
  });

  /// JSON -> 모델 변환
  factory BacktestResult.fromJson(Map<String, dynamic> json) {
    final stock = json['stock'];
    return BacktestResult(
      backtestId: (json['backtestId'] as num?)?.toInt(),
      stockId: (json['stockId'] as num?)?.toInt() ??
          (stock is Map ? (stock['id'] as num?)?.toInt() : null),
      stockName: (json['stockName'] ?? json['name'] ?? '').toString(),
      stockImage: (json['stockImage'] ?? '').toString(),
      executedAt: (json['executedAt'] ?? json['createdAt'] ?? '').toString(),
      startDate: (json['startDate'] ?? '').toString(),
      endDate: (json['endDate'] ?? '').toString(),
      matchedCount: (json['matchedCount'] as num?)?.toInt() ?? 0,
      winRate: (json['winRate'] as num?)?.toDouble() ?? 0,
      averageReturn: (json['averageReturn'] as num?)?.toDouble() ?? 0,
      maxReturn: (json['maxReturn'] as num?)?.toDouble() ?? 0,
      maxReturnDate: (json['maxReturnDate'] ?? '').toString(),
      minReturn: (json['minReturn'] as num?)?.toDouble() ?? 0,
      minReturnDate: (json['minReturnDate'] ?? '').toString(),
      totalReturn: (json['totalReturn'] as num?)?.toDouble() ?? 0,
      lastMatchedDate: (json['lastMatchedDate'] ?? '').toString(),
      lastMatchedReturn: (json['lastMatchedReturn'] as num?)?.toDouble() ?? 0,
      targetReturn: (json['targetReturn'] as num?)?.toDouble(),
    );
  }

  /// 모델 -> JSON 변환
  Map<String, dynamic> toJson() => {
    'backtestId': backtestId,
    'stockId': stockId,
    'stockName': stockName,
    'stockImage': stockImage,
    'executedAt': executedAt,
    'startDate': startDate,
    'endDate': endDate,
    'matchedCount': matchedCount,
    'winRate': winRate,
    'averageReturn': averageReturn,
    'maxReturn': maxReturn,
    'maxReturnDate': maxReturnDate,
    'minReturn': minReturn,
    'minReturnDate': minReturnDate,
    'totalReturn': totalReturn,
    'lastMatchedDate': lastMatchedDate,
    'lastMatchedReturn': lastMatchedReturn,
    'targetReturn': targetReturn,
  };
}