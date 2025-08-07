class Pattern {
  final String id;
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

  factory Pattern.fromJson(Map<String, dynamic> json) =>
      Pattern(
        id: json['id'].toString(),
        patternName: json['patternName'],
        points: List<int>.from(json['points']),
        tolerance: (json['tolerance'] as num).toDouble(),
        periodValue: json['periodValue'],
        periodUnit: json['periodUnit'],
      );

  Map<String, dynamic> toJson() =>
      {
        'id': id,
        'patternName': patternName,
        'points': points,
        'tolerance': tolerance,
        'periodValue': periodValue,
        'periodUnit': periodUnit,
      };
}