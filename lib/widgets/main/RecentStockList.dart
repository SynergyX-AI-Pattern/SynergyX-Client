import 'package:flutter/material.dart';
import 'package:stockapp/widgets/common/RecentStocks.dart';
import 'package:stockapp/widgets/main/StockItems.dart';

// 최근 조회 종목 리스트 카드
class RecentStockList extends StatelessWidget {
  const RecentStockList({super.key});

  @override
  Widget build(BuildContext context) {
    final recent = RecentStocks.recent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 16, right: 16, bottom: 8),
          child: Text('최근 조회 종목', style: TextStyles.title),
        ),

        if (recent.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Align(
                alignment: Alignment.centerLeft,
                child: Text('최근 조회한 종목이 없습니다.', style: TextStyles.content)),
          )
        else
          ...recent.map((stock) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
            child: StockItems(stock: stock),
          )),
      ],
    );
  }
}


// styles
class TextStyles {
  static const TextStyle title = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 20,
  );

  static const TextStyle content = TextStyle(
    fontWeight: FontWeight.w600,
    color: Color(0xFFAEAEAE),
  );
}
