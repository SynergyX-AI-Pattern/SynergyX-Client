class BacktestResult {
  final String stockName;
  final double averageReturn;
  final double winRate;
  final int matchedCount;
  final String executedAt;

  BacktestResult({
    required this.stockName,
    required this.averageReturn,
    required this.winRate,
    required this.matchedCount,
    required this.executedAt,
  });

  factory BacktestResult.fromJson(Map<String, dynamic> json) {
    return BacktestResult(
      stockName: (json['stockName'] ?? json['name'] ?? '').toString(),
      averageReturn: (json['averageReturn'] as num?)?.toDouble() ?? 0,
      winRate: (json['winRate'] as num?)?.toDouble() ?? 0,
      matchedCount: (json['matchedCount'] as num?)?.toInt() ?? 0,
      executedAt: (json['executedAt'] ?? json['createdAt'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stockName': stockName,
      'averageReturn': averageReturn,
      'winRate': winRate,
      'matchedCount': matchedCount,
      'executedAt': executedAt,
    };
  }
}

///  패턴 목록 (요약)
class Pattern {
  final int patternId;
  final String patternName;
  final List<int> points;
  final List<BacktestResult> recentBacktestResults;


  Pattern({
    required this.patternId,
    required this.patternName,
    required this.points,
    required this.recentBacktestResults,
  });


  factory Pattern.fromJson(Map<String, dynamic> json) {
    final pts = (json['points'] as List? ?? [])
        .map((e) => (e as num).toInt())
        .toList();

    final List<BacktestResult> backtests;
    final rawRecent = json['recentBacktestResults'];
    if (rawRecent is List) {
      backtests = rawRecent
          .whereType<Map>()
          .map((e) => BacktestResult.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } else if (json['backtestResult'] is Map) {
      backtests = [
        BacktestResult.fromJson(
            Map<String, dynamic>.from(json['backtestResult'] as Map)),
      ];
// ↑ [하위호환] 기존 단일 값을 리스트 1개로 감싸 제공
    } else {
      backtests = const [];
    }


    return Pattern(
      patternId: (json['patternId'] ?? json['id']) is num
          ? ((json['patternId'] ?? json['id']) as num).toInt()
          : int.tryParse((json['patternId'] ?? json['id'] ?? '0').toString()) ??
          0,
      patternName: (json['patternName'] ?? json['title'] ?? '').toString(),
      points: pts,
      recentBacktestResults: backtests,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patternId': patternId,
      'patternName': patternName,
      'points': points,
      'recentBacktestResults': recentBacktestResults.map((e) => e.toJson()).toList(),
      'id': patternId,
      'title': patternName,
    };
  }
}

/// 패턴 상세
class PatternDetail {
  final int patternId;
  final String patternName;
  final List<int> points;
  final double tolerance;
  final int periodValue;
  final String periodUnit;
  final List<Map<String, dynamic>> appliedStockList;
  final Map<String, dynamic>? backtestResult;


  PatternDetail({
    required this.patternId,
    required this.patternName,
    required this.points,
    required this.tolerance,
    required this.periodValue,
    required this.periodUnit,
    required this.appliedStockList,
    this.backtestResult,
  });

  factory PatternDetail.fromJson(Map<String, dynamic> json) {
    final pts = (json['points'] as List? ?? [])
        .map((e) => (e as num).toInt())
        .toList();

    final stocksRaw = json['appliedStockList'];
    final List<Map<String, dynamic>> stocks = [];
    if (stocksRaw is List) {
      for (final e in stocksRaw) {
        if (e is Map) {
          final m = Map<String, dynamic>.from(e as Map);
          final id = m['stockId'] ?? m['id'];
          final symbol = m['symbol']?.toString() ?? '';
          final stockName =
              m['stockName'] ?? m['name'] ?? symbol; // 이름 정보 우선순위
          final stockImage = m['stockImage'] ?? m['imageUrl'] ?? '';

          stocks.add({
            'stockId': id,
            'symbol': symbol,
            'stockName': stockName,
            'stockImage': stockImage,
            'name': stockName, // 기존 코드 호환을 위해 name 도 유지
          });
        } else {
          // Map 이 아닌 경우 대비: 문자열만 들어오면 기본 구조로 저장
          stocks.add({
            'stockId': null,
            'symbol': e.toString(),
            'stockName': e.toString(),
            'stockImage': '',
            'name': e.toString(),
          });
        }
      }
    }

    return PatternDetail(
      patternId: (json['patternId'] ?? json['id']) is num
          ? ((json['patternId'] ?? json['id']) as num).toInt()
          : int.tryParse((json['patternId'] ?? json['id'] ?? '0').toString()) ?? 0,
      patternName: (json['patternName'] ?? json['title'] ?? '').toString(),
      points: pts,
      tolerance: (json['tolerance'] as num?)?.toDouble() ?? 0,
      periodValue: (json['periodValue'] as num?)?.toInt() ?? 0,
      periodUnit: (json['periodUnit'] as String?) ?? 'DAY',
      appliedStockList: stocks,
      backtestResult: json['backtestResult'] as Map<String, dynamic>?,
    );
  }

  /// 수정 페이지에 넘겨줄 때 쓰는 toJson
  Map<String, dynamic> toJson() {
    return {
      'id': patternId,
      'title': patternName,

      'patternId': patternId,
      'patternName': patternName,
      'points': points,
      'tolerance': double.parse(tolerance.toStringAsFixed(2)),
      'periodValue': periodValue,
      'periodUnit': periodUnit,
      'appliedStockList': appliedStockList,
      'backtestResult': backtestResult,
    };
  }
}


