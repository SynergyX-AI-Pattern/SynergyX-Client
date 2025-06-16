import 'package:flutter/material.dart';
import '../../models/stock.dart';

class SearchStockItem extends StatelessWidget {
  final Stock stock;
  final VoidCallback onTap;

  const SearchStockItem({
    super.key,
    required this.stock,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Image.network(stock.imageUrl, width: 30, height: 30),
      title: Text(stock.name, style: TextStyle(fontWeight: FontWeight.w600),),
      onTap: onTap,
    );
  }
}
