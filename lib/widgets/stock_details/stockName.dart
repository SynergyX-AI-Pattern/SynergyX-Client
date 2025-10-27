import 'package:flutter/material.dart';
import 'package:stockapp/data/watchlist_api.dart';
import 'package:stockapp/models/stock_detail_model.dart';
import 'package:stockapp/services/watchlist_event.dart';

class StockName extends StatefulWidget {
  final StockDetailResponse detail;
  final String stockId;

  const StockName({super.key, required this.detail, required this.stockId});

  @override
  State<StockName> createState() => _StockNameState();
}

class _StockNameState extends State<StockName> {
  late bool isFavorite;
  bool _busy = false;
  final WatchlistApiService _apiService2 = WatchlistApiService();

  @override
  void initState() {
    super.initState();
    isFavorite = widget.detail.isWatchlist;  // API값으로 초기화
  }

  @override
  Widget build(BuildContext context) {
    final detail = widget.detail;
    final changeText = '${detail.changeAmount}(${detail.changeRate})';

    return Padding(
      padding: const EdgeInsets.only(left: 28, right: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(detail.stockName, style: AppStyles.title),
              Text(detail.price, style: AppStyles.cost),
              Text(changeText,
                  style: AppStyles.profit.copyWith(color: const Color(0xFFDF1525))),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: IconButton(
              onPressed: () async {
                final previousState = isFavorite;

                setState(() {
                  isFavorite = !isFavorite;
                  _busy = true;
                });

                try {
                  if (isFavorite) {
                    await _apiService2.addToWatchlist(widget.stockId);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('관심종목에 등록되었습니다.')),
                    );
                  } else {
                    await _apiService2.removeFromWatchlist(widget.stockId);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('관심종목에서 해제되었습니다.')),
                    );
                  }
                  // 관심목록이 바뀌었음을 알림
                  watchlistChangedNotifier.value = true;
                } catch (e) {
                  setState(() {
                    isFavorite = previousState;
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('관심종목 처리 실패!')),
                  );
                }
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
  }
}

class AppStyles {
  static const TextStyle title =
  TextStyle(fontWeight: FontWeight.w700, fontSize: 20);
  static const TextStyle cost =
  TextStyle(fontWeight: FontWeight.w700, fontSize: 36);
  static const TextStyle profit = TextStyle(
      fontWeight: FontWeight.w500, fontSize: 16, color: Colors.red);
}
