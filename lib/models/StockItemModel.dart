class StockItem {
  final int rank;
  final int stockId;
  final String name;
  final int price;
  final double changeRate;
  final String imageUrl;

  StockItem({
    required this.rank,
    required this.stockId,
    required this.name,
    required this.price,
    required this.changeRate,
    required this.imageUrl,
  });

  factory StockItem.fromJson(Map<String, dynamic> json) {
    return StockItem(
      rank: json['rank'],
      stockId: json['stockId'],
      name: json['stockName'],
      price: int.parse(json['price'].replaceAll(',', '')),
      changeRate: double.parse(json['changeRate'].replaceAll('%', '')),
      imageUrl: json['imageUrl'],
    );
  }
}
