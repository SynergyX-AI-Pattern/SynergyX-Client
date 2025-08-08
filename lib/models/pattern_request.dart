class PatternRequest {
  final int id;
  final String patternName;
  final List<int> points;
  final double tolerance;
  final int periodValue;
  final String periodUnit; // "HOUR" 또는 "DAY"로 제한

  PatternRequest({
    required this.id,
    required this.patternName,
    required this.points,
    required this.tolerance,
    required this.periodValue,
    required this.periodUnit,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    '': patternName,
    'points': points,
    'tolerance': tolerance,
    'periodValue': periodValue,
    'periodUnit': periodUnit.toUpperCase(),
  };

  factory PatternRequest.fromJson(Map<String, dynamic> json) {
    return PatternRequest(
      id: json['patternId'] is int
          ? json['patternId']
          : int.parse(json['patternId'].toString()),
      patternName: json['patternName'] ?? '이름없음',
      points: (json['points'] as List)
          .map((e) => (e as num).toInt())
          .toList(),
      tolerance: (json['tolerance'] ?? 0.0) as double,
      periodValue: json['periodValue'] ?? 0,
      periodUnit: json['periodUnit'] ?? 'day',
    );
  }
}
