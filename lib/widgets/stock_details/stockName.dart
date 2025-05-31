import 'package:flutter/material.dart';

// StockName
class StockName extends StatefulWidget {
  const StockName({super.key});

  @override
  State<StockName> createState() => _StockNameState();
}

class _StockNameState extends State<StockName> {
  bool isFavorite = false; // 초기 상태: 빈 하트

  @override
  Widget build(BuildContext context) {
    // 실제 데이터(하드코딩 -> API)
    final int changeAmount = 600;
    final double changeRate = 1.12;
    // 등락률,금액 출력 컬러
    final bool isRising = changeAmount >= 0;
    final Color changeColor = isRising ? Color(0xFFDF1525) : Color(0xFF1573FE);
    // 부호
    final String sign = isRising ? '+' : '';
    final String changeText =
        '$sign${changeAmount.abs()}(${changeRate.abs().toStringAsFixed(2)}%)';

    return Padding(
        padding: const EdgeInsets.only(left: 28, right: 15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('삼성전자', style: AppStyles.title),
                Text('54,300', style: AppStyles.cost),
                Text(changeText,
                  style: AppStyles.profit.copyWith(color: changeColor),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: IconButton(
                onPressed: () {
                  setState(() {
                    isFavorite = !isFavorite; // 상태 토글
                  });
                },
                icon: Icon(
                  isFavorite
                      ? Icons.favorite      // 채운 하트
                      : Icons.favorite_outline, // 빈 하트
                  size: 45,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
    );
  }
}

// styles
class AppStyles {
  static const TextStyle title = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 20,
  );

  static const TextStyle cost = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 36,
  );

  static const TextStyle profit = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 16,
    color: Colors.red,
  );
}
