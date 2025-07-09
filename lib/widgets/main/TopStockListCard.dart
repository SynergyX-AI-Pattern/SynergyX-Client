import 'package:flutter/material.dart';
import 'package:stockapp/screens/stock_detail_screen.dart';
import 'package:stockapp/screens/topStock_screen.dart';
import 'package:stockapp/models/StockItemModel.dart';
import 'package:stockapp/widgets/common/RecentStocks.dart';
import 'package:stockapp/widgets/main/StockRankItem.dart';

// Top 20 리스트 카드
class TopStockListCard extends StatelessWidget {
  final List<StockItem> stockList;
  final String title;

  const TopStockListCard({super.key, required this.stockList, required this.title});

  @override
  Widget build(BuildContext context) {
    final topFive = stockList.take(5).toList(); // 상위 5개만 표시

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단 텍스트
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('10시 기준', style: TextStyles.timeText),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Text(title, style: TextStyles.topText),
                  ),
                ],
              ),
            ),

            // 구분선
            Container(
              width: 500,
              child: Divider(color: Color(0xFFD9D9D9), thickness: 1.0),
            ),

            // 종목 리스트
            ...topFive.map((stock) {
              return GestureDetector(
                //종목 상세 페이지로 이동
                onTap: () {
                  RecentStocks.add(stock);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => DetailScreen(stock: stock)),
                  );
                },
                child: StockRankItem(stock: stock),
              );
            }),

            const SizedBox(height: 12),

            // 더보기 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => TopStocksScreen(stockList: stockList, stockTitle: title),
                    ),
                  );
                },
                child: const Text('더보기', style: TextStyles.buttonText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TextStyles {
  static const TextStyle timeText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Colors.grey,
  );

  static const TextStyle topText = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle buttonText = TextStyle(fontWeight: FontWeight.w700);
}
