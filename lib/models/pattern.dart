class Pattern {
  final int patternId;
  final String patternName;
  final List<int> points;       // 서버는 [6.0,2.0,...] 줄 수 있어도 앱 내부는 int로 사용
  final double tolerance;       // 0.1 같은 소수
  final int periodValue;        // 3,5,7...
  final String periodUnit;      // 'DAY' | 'HOUR'
  final List<String> appliedStockList; // 서버가 [] 또는 문자열 배열/객체 배열일 수 있어 안전 변환
  final dynamic backtestResult;        // null 허용

  Pattern({
    required this.patternId,
    required this.patternName,
    required this.points,
    required this.tolerance,
    required this.periodValue,
    required this.periodUnit,
    required this.appliedStockList,
    required this.backtestResult,
  });

  factory Pattern.fromJson(Map<String, dynamic> json) {
    final pts = (json['points'] as List?)
        ?.map((e) => (e as num).toInt())
        .toList()
        ?? const <int>[];

    // appliedStockList가 [{symbol,name}] 형태일 수도, ["AAPL"]일 수도, null일 수도 있음
    final stocksRaw = json['appliedStockList'];
    final stocks = <String>[];
    if (stocksRaw is List) {
      for (final e in stocksRaw) {
        if (e is Map) {
          final name = e['name']?.toString();
          final symbol = e['symbol']?.toString();
          if (name != null && name.isNotEmpty) {
            stocks.add(name);
          } else if (symbol != null && symbol.isNotEmpty) {
            stocks.add(symbol);
          }
        } else {
          stocks.add(e.toString());
        }
      }
    }

    return Pattern(
      patternId: (json['patternId'] as num).toInt(),
      patternName: (json['patternName'] as String?) ?? (json['title'] as String?) ?? '',
      points: pts,
      tolerance: (json['tolerance'] as num?)?.toDouble() ?? 0.1,
      periodValue: (json['periodValue'] as num?)?.toInt() ?? 0,
      periodUnit: (json['periodUnit'] as String?) ?? 'DAY',
      appliedStockList: stocks,
      backtestResult: json['backtestResult'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // 서버 규격
      'patternId': patternId,
      'patternName': patternName,
      'points': points,               // 서버는 double도 받지만 int 배열로 보내도 OK
      'tolerance': double.parse(tolerance.toStringAsFixed(2)),
      'periodValue': periodValue,
      'periodUnit': periodUnit,

      'appliedStockList': appliedStockList, // 필요 시 서버 규격에 맞게 바꿔도 됨
      'backtestResult': backtestResult,

      // 👇 화면 코드 호환용 alias (기존에 data['id'], data['title'] 사용)
      'id': patternId,
      'title': patternName,
    };
  }
}
