class PatternRequest {
  final String patternName;
  final List<int> points;
  final double tolerance;
  final int periodValue;
  final String periodUnit;

  PatternRequest({
    required this.patternName,
    required this.points,
    required this.tolerance,
    required this.periodValue,
    required this.periodUnit,
  });

  Map<String, dynamic> toJson() {
    return {
      'patternName': patternName,
      'points': points,
      'tolerance': tolerance,
      'periodValue': periodValue,
      'periodUnit': periodUnit,
    };
  }

  factory PatternRequest.fromJson(Map<String, dynamic> json) {
    return PatternRequest(
      patternName: json['patternName'],
      points: List<int>.from(json['points']),
      tolerance: (json['tolerance'] as num).toDouble(),
      periodValue: json['periodValue'],
      periodUnit: json['periodUnit'],
    );
  }
}
