import 'package:flutter/material.dart';
import 'package:stockapp/data/stock_detail_api.dart';
import 'package:stockapp/models/stock_detail_model.dart';

// StockName
class StockName extends StatefulWidget {
  final String stockId;

  const StockName({super.key, required this.stockId});

  @override
  State<StockName> createState() => _StockNameState();
}

class _StockNameState extends State<StockName> {
  bool isFavorite = false;
  late Future<StockDetailResponse> _stockNameFuture;

  @override
  void initState() {
    super.initState();
    _stockNameFuture = fetchStockDetail(widget.stockId); // 예시 종목 코드
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<StockDetailResponse>(
      future: _stockNameFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Text('에러 발생: ${snapshot.error}');
        }

        final data = snapshot.data!;

        final String changeAmount = data.changeAmount;
        final String changeRate = data.changeRate;
        //final bool isRising = changeAmount >= 0;
        //final Color changeColor = isRising ? Color(0xFFDF1525) : Color(0xFF1573FE);
        //final String sign = isRising ? '+' : '';
        final String changeText =
            '$changeAmount($changeRate)';

        return Padding(
          padding: const EdgeInsets.only(left: 28, right: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(data.stockName, style: AppStyles.title),
                  Text('${data.price}', style: AppStyles.cost),
                  Text(changeText,
                      style: AppStyles.profit.copyWith(color: Color(0xFFDF1525))),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      isFavorite = !isFavorite;
                    });
                  },
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_outline,
                    size: 45,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
