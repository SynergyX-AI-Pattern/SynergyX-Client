// backtest_result.dart

class StockResult {
  final int id;
  final String name;
  final String imageUrl;

  StockResult({
    required this.id,
    required this.name,
    required this.imageUrl,
  });

  factory StockResult.fromJson(Map<String, dynamic> json) {
    return StockResult(
      id: (json['id'] as num).toInt(),
      name: (json['name'] ?? '').toString(),
      imageUrl: (json['imageUrl'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
    };
  }
}

/// 백테스트 결과 모델
class BacktestResult {
  final int? backtestId;
  final List<StockResult> stockResults; // ✅ lowerCamelCase
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
    required this.stockResults, // ✅ lowerCamelCase
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
    // 새 키(소문자) 우선, 구버전 대소문자 키 하위호환
    final rawList = json['stockResults'] ?? json['StockResults'];
    List<StockResult> stocks;
    if (rawList is List) {
      stocks = rawList
          .whereType<Map>()
          .map((e) => StockResult.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } else if (json['stockResult'] is Map) {
      stocks = [
        StockResult.fromJson(
          Map<String, dynamic>.from(json['stockResult'] as Map),
        ),
      ];
    } else if (json['StockResult'] is Map) {
      // 구버전 단일 키도 지원
      stocks = [
        StockResult.fromJson(
          Map<String, dynamic>.from(json['StockResult'] as Map),
        ),
      ];
    } else {
      stocks = const [];
    }

    return BacktestResult(
      backtestId: (json['backtestId'] as num?)?.toInt(),
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
      stockResults: stocks, // ✅ 리스트를 그대로 대입 (중첩 X)
    );
  }

  /// 모델 -> JSON 변환
  Map<String, dynamic> toJson() => {
    'backtestId': backtestId,
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
    'stockResults': stockResults.map((e) => e.toJson()).toList(), // ✅ 소문자 키
  };
}
