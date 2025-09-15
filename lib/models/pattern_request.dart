class PatternRequest {
  final int patternId;
  final String patternName;
  final List<int> points;
  final double tolerance;
  final int periodValue;
  final String periodUnit;

  PatternRequest({
    required this.patternId,
    required this.patternName,
    required this.points,
    required this.tolerance,
    required this.periodValue,
    required this.periodUnit,
  });

  Map<String, dynamic> toJson() => {
    'patternId': patternId,
    'patternName': patternName,
    'points': points,
    'tolerance': tolerance,
    'periodValue': periodValue,
    'periodUnit': periodUnit.toUpperCase(),
  };

  factory PatternRequest.fromJson(Map<String, dynamic> json) {
    final rawTolerance = json['tolerance'];
    final rawPeriod = json['periodValue'];

    return PatternRequest(
      patternId: json['patternId'] is int
          ? json['patternId']
          : int.parse(json['patternId'].toString()),
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
