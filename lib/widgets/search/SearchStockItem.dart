import 'package:flutter/material.dart';
import 'package:stockapp/models/stock.dart';

class SearchStockItem extends StatelessWidget {
  final Stock stock;
  final VoidCallback? onTap;

  const SearchStockItem({
    super.key,
    required this.stock,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const CircleAvatar(
        backgroundColor: Colors.blue,
      ),
      title: Text(
        stock.name,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      onTap: onTap,
    );
  }
}
