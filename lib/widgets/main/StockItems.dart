import 'package:flutter/material.dart';
import 'package:stockapp/models/StockItemModel.dart';
import 'package:intl/intl.dart';

class StockItems extends StatelessWidget {
  final StockItem stock;

  const StockItems({super.key, required this.stock});

  @override
  Widget build(BuildContext context) {
    final isUp = stock.changeRate >= 0;
    final numberFormat = NumberFormat('#,###');

    return Row(
      children: [
        // 아이콘 영역
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Container(
            width: 45,
            height: 45,
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFB),
              //color: Colors.red,
              borderRadius: BorderRadius.all(Radius.circular(50)),
            ),
          ),
        ),

        const SizedBox(width: 10),

        // 종목명
        Expanded(
          flex: 2,
          child: Text(stock.name, style: TextStyles.symbolText),
        ),

        // 가격 + 등락률
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${numberFormat.format(stock.price)}원',
                textAlign: TextAlign.right,
                style: TextStyles.costText,
              ),
              Text(
                '${isUp ? '+' : ''}${stock.changeRate.toStringAsFixed(2)}%',
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 14,
                  color:
                      isUp ? const Color(0xFFDF1525) : const Color(0xFF1573FE),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 10),
      ],
    );
  }
}

class TextStyles {
  static const TextStyle costText = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 14,
  );

  static const TextStyle symbolText = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
  );
}
