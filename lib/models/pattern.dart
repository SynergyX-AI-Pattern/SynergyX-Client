class Pattern {
  final int id;
  final String patternName;
  final List<int> points;
  final double tolerance;
  final int periodValue;
  final String periodUnit;

  Pattern({
    required this.id,
    required this.patternName,
    required this.points,
    required this.tolerance,
    required this.periodValue,
    required this.periodUnit,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patternName': patternName,
      'points': points,
      'tolerance': tolerance,
      'periodValue': periodValue,
      'periodUnit': periodUnit,
    };
  }

  factory Pattern.fromJson(Map<String, dynamic> json) {
    // 서버에서 숫자 값을 문자열로 보내는 경우를 대비하여 형 변환을 진행.
    final rawTolerance = json['tolerance'];
    final rawPeriod = json['periodValue'];

    return Pattern(
      id: json['patternId'] is String
          ? int.tryParse(json['patternId']) ?? 0
          : (json['patternId'] as num?)?.toInt() ?? 0,
      patternName: (json['patternName'] ?? '이름없음').toString(),
      points: (json['points'] as List).map((e) => (e as num).toInt()).toList(),
      tolerance: rawTolerance is String
          ? double.tryParse(rawTolerance) ?? 0.0
          : (rawTolerance as num?)?.toDouble() ?? 0.0,
      periodValue: rawPeriod is String
          ? int.tryParse(rawPeriod) ?? 0
          : (rawPeriod as num?)?.toInt() ?? 0,
      periodUnit: (json['periodUnit'] ?? 'DAY').toString(),
    );
  }

}
