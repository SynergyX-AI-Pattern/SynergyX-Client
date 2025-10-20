import 'package:flutter/material.dart';
import 'package:stockapp/models/StockItemModel.dart'; // 시세 모델
import 'package:stockapp/models/stock_brief.dart';
import 'package:stockapp/screens/interest/interest_pattern_screen.dart';
import 'package:stockapp/screens/stock_detail_screen.dart';
import 'package:stockapp/widgets/common/app_button.dart';
import 'package:stockapp/widgets/main/StockItems.dart'; // 재사용 타일

class WatchlistItem extends StatelessWidget {
  final StockBrief stock;
  final VoidCallback? onTap;

  const WatchlistItem({super.key, required this.stock, this.onTap});

  @override
  Widget build(BuildContext context) {
    final merged = StockItem(
      rank: 0,
      stockId: stock.stockId,
      name: stock.stockName,
      price: int.tryParse(stock.price.toString().replaceAll(',', '')) ?? 0,
      changeRate:
          double.tryParse(stock.changeRate.toString().replaceAll('%', '')) ??
          0.0,
      imageUrl: stock.imageUrl,
    );

    return StockItems(
      stock: merged,
      onTap: (){
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailScreen(
              stock: StockItem(
                stockId: stock.stockId,
                name: stock.stockName,
                price: int.tryParse(stock.price.replaceAll(',', '')) ?? 0,
                changeRate: double.tryParse(stock.changeRate.replaceAll('%', '')) ?? 0.0,
                imageUrl: stock.imageUrl,
                rank: 0,
              ),
            ),
          ),
        );
      },
      // 관심종목 전용 오른쪽 액션들
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppButton(
            label: '패턴',
            minHeight: 36,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder:
                      (_) => InterestPatternScreen(
                        stockId: stock.stockId,
                        stockName: stock.stockName,
                        stockImageUrl: stock.imageUrl,
                      ),
                ),
              );
            },
          ),
        ],
      ),
      // 화면에 맞게 여백 살짝
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
    );
  }
}
