class Stock {
  final int id;
  final String name;
  final String imageUrl;

  Stock({
    required this.id,
    required this.name,
    required this.imageUrl,
  });

  factory Stock.fromJson(Map<String, dynamic> json) {
    return Stock(
      id: json['id'],
      name: json['name'],
      imageUrl: json['imageUrl'],
    );
  }
}
