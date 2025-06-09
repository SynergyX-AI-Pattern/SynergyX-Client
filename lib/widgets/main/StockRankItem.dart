import 'package:flutter/material.dart';
import 'package:stockapp/models/StockItemModel.dart';
import 'package:stockapp/widgets/main/StockItems.dart';

// 주식 종목 카드
class StockRankItem extends StatelessWidget {
  final StockItem stock;

  const StockRankItem({super.key, required this.stock});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text(
              '${stock.rank}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 20,
                color: Color(0xFF757575),
              ),
            ),
          ),
          Expanded(child: StockItems(stock: stock)), // 주식 종목 호출
        ],
      ),
    );
  }
}
