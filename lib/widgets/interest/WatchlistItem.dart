import 'package:flutter/material.dart';
import 'package:stockapp/models/stock.dart';
import 'package:stockapp/models/StockItemModel.dart';        // 시세 모델
import 'package:stockapp/screens/interest/interest_pattern_screen.dart';
import 'package:stockapp/widgets/common/app_button.dart';
import 'package:stockapp/widgets/main/StockItems.dart'; // 재사용 타일

class WatchlistItem extends StatelessWidget {
  /// 기본 종목 정보 (id, name, image)
  final Stock stock;

  /// 시세 정보(가격/등락률). 없으면 0으로 표시(또는 StockItems가 null 허용이면 null 전달)
  final StockItem? quote;

  final VoidCallback? onTap;

  const WatchlistItem({
    super.key,
    required this.stock,
    this.quote,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Stock + Quote 병합해서 StockItems에 넣기
    final merged = StockItem(
      rank: quote?.rank ?? 0,
      stockId: stock.id,
      name: stock.name,
      price: quote?.price ?? 0,              // 여기서 null 허용이면 null 넘겨도 OK
      changeRate: quote?.changeRate ?? 0.0,  // ↑ 같은 맥락
      imageUrl: stock.imageUrl,
    );

    return StockItems(
      stock: merged,
      onTap: onTap,
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
                  builder: (_) => InterestPatternScreen(
                    stockId: stock.id,
                    stockName: stock.name,
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
