import 'package:intl/intl.dart';

class BacktestRanking {
  BacktestRanking({
    required this.rank,
    required this.userId,
    required this.username,
    this.image,
    required this.winRate,
    required this.averageReturn,
    required this.maxReturn,
    this.maxReturnDate,
    required this.backtestId,
  });

  final int rank;
  final int userId;
  final String username;
  final String? image;
  final double winRate;
  final double averageReturn;
  final double maxReturn;
  final DateTime? maxReturnDate;
  final int backtestId;

  factory BacktestRanking.fromJson(Map<String, dynamic> json) {
    DateTime? parsedDate;
    final rawDate = json['maxReturnDate'];
    if (rawDate is String && rawDate.isNotEmpty) {
      parsedDate = DateTime.tryParse(rawDate);
    }

    return BacktestRanking(
      rank: (json['rank'] as num?)?.toInt() ?? 0,
      userId: (json['userId'] as num?)?.toInt() ?? 0,
      username: json['username']?.toString() ?? '',
      image: json['image']?.toString(),
      winRate: (json['winRate'] as num?)?.toDouble() ?? 0,
      averageReturn: (json['averageReturn'] as num?)?.toDouble() ?? 0,
      maxReturn: (json['maxReturn'] as num?)?.toDouble() ?? 0,
      maxReturnDate: parsedDate,
      backtestId: (json['backtestId'] as num?)?.toInt() ?? 0,
    );
  }

  String get formattedMaxReturnDate {
    if (maxReturnDate == null) return '-';
    final formatter = DateFormat('yyyy.MM.dd');
    return formatter.format(maxReturnDate!);
  }
}