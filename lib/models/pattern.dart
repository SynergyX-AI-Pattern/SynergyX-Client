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
    return Pattern(
      id: json['patternId'] is String
          ? int.tryParse(json['patternId']) ?? 0
          : (json['patternId'] as num?)?.toInt() ?? 0,
      patternName: (json['patternName'] ?? '이름없음').toString(),
      points: (json['points'] as List).map((e) => (e as num).toInt()).toList(),
      tolerance: (json['tolerance'] as num?)?.toDouble() ?? 0.0,
      periodValue: (json['periodValue'] as num?)?.toInt() ?? 0,
      periodUnit: (json['periodUnit'] ?? 'DAY').toString(),
    );
  }

}
