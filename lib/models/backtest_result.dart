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
      imageUrl: (json['imageUrl'] ?? json['stockImage'] ?? '').toString(),
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

/// 하이라이트 범위 모델
class HighlightRange {
  final DateTime? fromDate;
  final DateTime? toDate;

  const HighlightRange({this.fromDate, this.toDate});

  factory HighlightRange.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const HighlightRange();
    DateTime? parse(String? s) {
      if (s == null || s.isEmpty) return null;
      // ISO-8601(yyyy-MM-dd or yyyy-MM-ddTHH:mm:ss) 모두 대응
      return DateTime.tryParse(s);
    }

    return HighlightRange(
      fromDate: parse(json['fromDate']?.toString()),
      toDate: parse(json['toDate']?.toString()),
    );
  }

  Map<String, dynamic> toJson() => {
    'fromDate': fromDate?.toIso8601String(),
    'toDate': toDate?.toIso8601String(),
  };
}

/// 백테스트 결과 모델
class BacktestResult {
  final int? backtestId;
  final List<StockResult> stockResults;
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
  final HighlightRange? highlightRange;
  final String? periodUnit; // "HOUR" | "DAY" | "MINUTE" 등 서버 스펙

  BacktestResult({
    this.backtestId,
    required this.stockResults,
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
    this.highlightRange,
    this.periodUnit,
  });

  /// JSON -> 모델 변환 (신/구 키 혼용 대응)
  factory BacktestResult.fromJson(Map<String, dynamic> json) {
    // stockResults 배열(신규) 또는 단일 객체(구버전) 대응
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
      stocks = [
        StockResult.fromJson(
          Map<String, dynamic>.from(json['StockResult'] as Map),
        ),
      ];
    } else if (json['stock'] is Map) {
      // 서버가 stock 단일 객체만 주는 경우도 일부 고려
      final m = Map<String, dynamic>.from(json['stock'] as Map);
      stocks = [
        StockResult.fromJson({
          'id': m['id'],
          'name': m['name'],
          'imageUrl': m['imageUrl'] ?? m['stockImage'],
        })
      ];
    } else {
      stocks = const [];
    }

    // 숫자 안전 파싱
    double d(dynamic v) => (v is num) ? v.toDouble() : double.tryParse('$v') ?? 0.0;
    int i(dynamic v) => (v is num) ? v.toInt() : int.tryParse('$v') ?? 0;

    return BacktestResult(
      backtestId: (json['backtestId'] as num?)?.toInt(),
      executedAt: (json['executedAt'] ?? json['createdAt'] ?? '').toString(),
      startDate: (json['startDate'] ?? '').toString(),
      endDate: (json['endDate'] ?? '').toString(),
      matchedCount: i(json['matchedCount']),
      winRate: d(json['winRate']),
      averageReturn: d(json['averageReturn']),
      maxReturn: d(json['maxReturn']),
      maxReturnDate: (json['maxReturnDate'] ?? '').toString(),
      minReturn: d(json['minReturn']),
      minReturnDate: (json['minReturnDate'] ?? '').toString(),
      totalReturn: d(json['totalReturn']),
      lastMatchedDate: (json['lastMatchedDate'] ?? '').toString(),
      lastMatchedReturn: d(json['lastMatchedReturn']),
      targetReturn: (json['targetReturn'] is num)
          ? (json['targetReturn'] as num).toDouble()
          : double.tryParse('${json['targetReturn']}'),
      stockResults: stocks,
      highlightRange: HighlightRange.fromJson(
        (json['highlightRange'] is Map) ? Map<String, dynamic>.from(json['highlightRange']) : null,
      ),
      periodUnit: (json['periodUnit'] ?? json['PeriodUnit'])?.toString(),
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
    'stockResults': stockResults.map((e) => e.toJson()).toList(),
    'highlightRange': highlightRange?.toJson(),
    'periodUnit': periodUnit,
  };
}
