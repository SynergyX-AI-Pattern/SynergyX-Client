import 'package:flutter/material.dart';
import 'package:stockapp/models/StockItemModel.dart';

class StockRankItem extends StatelessWidget {
  final StockItem stock;

  const StockRankItem({super.key, required this.stock});

  @override
  Widget build(BuildContext context) {
    final isUp = stock.changeRate >= 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          // 순위 (or 아이콘)
          SizedBox(
            width: 30,
            child: Text(
              '${stock.rank}',
              style: TextStyles.rankText,
              textAlign: TextAlign.center,
            ),
          ),

          //이미지
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Container(
              width: 45,
              height: 45,
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFB),
                borderRadius: BorderRadius.all(Radius.circular(50)),
              ),
            ),
          ),

          SizedBox(width: 10),

          // 종목명 (심볼 + 이름)
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(stock.symbol, style: TextStyles.symbolText),
                Text(stock.name, style: TextStyles.nameText),
              ],
            ),
          ),

          // 가격 + 등락률
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${stock.price.toStringAsFixed(0)}\원',
                  textAlign: TextAlign.right,
                  style: TextStyles.costText,
                ),
                Text(
                  '${isUp ? '+' : ''}${stock.changeRate.toStringAsFixed(2)}%',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 14,
                    color: isUp ? Color(0xFFDF1525) : Color(0xFF1573FE),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: 10),
        ],
      ),
    );
  }
}

//style
class TextStyles {
  static const TextStyle rankText = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 20,
    color: Color(0xFF757575),
  );

  static const TextStyle costText = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 14,
  );

  static const TextStyle nameText = TextStyle(fontSize: 12, color: Colors.grey);

  static const TextStyle symbolText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
  );
}
