//pattern.

class Pattern {
  final int patternId;
  final String patternName;
  final List<int> points;       // 서버는 [6.0,2.0,...] 줄 수 있어도 앱 내부는 int로 사용
  final double tolerance;       // 0.1 같은 소수
  final int periodValue;        // 3,5,7...
  final String periodUnit;      // 'DAY' | 'HOUR'
  final List<Map<String, dynamic>> appliedStockList; // 적용 종목 목록
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

    final stocksRaw = json['appliedStockList'];
    final stocks = <Map<String, dynamic>>[];
    if (stocksRaw is List) {
      for (final e in stocksRaw) {
        if (e is Map<String, dynamic>) {
          final id = e['stockId'] ?? e['id'];
          final name = e['name'] ?? e['symbol'] ?? '';
          stocks.add({'stockId': id, 'name': name});
        } else {
          // 문자열만 넘어올 경우 이름만 저장
          stocks.add({'stockId': null, 'name': e.toString()});
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