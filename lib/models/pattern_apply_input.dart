class PatternApplyInput {
  final DateTime entryAt;      // UTC로 전달
  final double minValidReturn; // 소수 허용

  PatternApplyInput({
    required this.entryAt,
    required this.minValidReturn,
  });
}
