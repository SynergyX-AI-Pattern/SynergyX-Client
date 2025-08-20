// lib/models/stock_brief.dart
class StockBrief {
  final int id;
  final String name;
  final String symbol;
  final String imageUrl;

  StockBrief({
    required this.id,
    required this.name,
    required this.symbol,
    required this.imageUrl,
  });

  factory StockBrief.fromJson(Map<String, dynamic> json) => StockBrief(
    id: json['stockId'] as int,
    name: json['stockName'] as String,
    symbol: json['stockSymbol'] as String,
    imageUrl: json['imageUrl'] as String? ?? '',
  );
}
