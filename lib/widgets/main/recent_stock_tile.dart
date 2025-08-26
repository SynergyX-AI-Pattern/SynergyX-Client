import 'package:flutter/material.dart';
import 'package:stockapp/models/stock_brief.dart';

class RecentStockTile extends StatelessWidget {
  final StockBrief stock;
  final VoidCallback? onTap;
  const RecentStockTile({super.key, required this.stock, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          ClipOval(
            child: Image.network(
              stock.imageUrl,
              width: 40, height: 40, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => CircleAvatar(
                radius: 20, backgroundColor: const Color(0xFFF1F3F5),
                child: Text(stock.name.isNotEmpty ? stock.name.characters.first : '?'),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              stock.name,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
