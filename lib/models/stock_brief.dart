class StockBrief {
  final int stockId;
  final String stockName;
  final String stockSymbol;
  final String price;
  final String changeRate;
  final String imageUrl;

  StockBrief({
    required this.stockId,
    required this.stockName,
    required this.stockSymbol,
    required this.price,
    required this.changeRate,
    required this.imageUrl,
  });

  factory StockBrief.fromJson(Map<String, dynamic> json) => StockBrief(
    stockId: json['stockId'] as int,
    stockName: json['stockName'] as String,
    stockSymbol: json['stockSymbol'] as String,
    price: json['price'] as String,
    changeRate: json['changeRate'] as String,
    imageUrl: json['imageUrl'] as String? ?? '',
  );
}
