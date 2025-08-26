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
      leading: ClipOval(
        child: Image.network(
          stock.imageUrl, // 주식 이미지 url
          width: 40,
          height: 40,
          fit: BoxFit.cover,
        ),
      ),
      title: Text(stock.name, style: TextStyle(fontWeight: FontWeight.w600),),
      onTap: onTap,
    );
  }
}
