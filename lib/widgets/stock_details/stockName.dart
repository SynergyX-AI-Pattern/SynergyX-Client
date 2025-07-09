import 'package:flutter/material.dart';
import 'package:stockapp/data/stock_detail_api.dart';
import 'package:stockapp/models/stock_detail_model.dart';
import 'package:stockapp/data/watchlist_api.dart';

class StockName extends StatefulWidget {
  final String stockId;

  const StockName({super.key, required this.stockId});

  @override
  State<StockName> createState() => _StockNameState();
}

class _StockNameState extends State<StockName> {
  bool isFavorite = false;
  late Future<StockDetailResponse> _stockNameFuture;
  final StockDetailApiService _apiService = StockDetailApiService();
  final WatchlistApiService _apiService2 = WatchlistApiService();

  @override
  void initState() {
    super.initState();
    _stockNameFuture = _apiService.fetchStockDetail(widget.stockId);
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

        final String changeText = '${data.changeAmount}(${data.changeRate})';

        return Padding(
          padding: const EdgeInsets.only(left: 28, right: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(data.stockName, style: AppStyles.title),
                  Text(data.price, style: AppStyles.cost),
                  Text(changeText, style: AppStyles.profit.copyWith(color: const Color(0xFFDF1525))),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: IconButton(
                  onPressed: () async {
                    final previousState = isFavorite; // 현재 상태 저장

                    setState(() {
                      isFavorite = !isFavorite; // 하트 상태 토글
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
                    } catch (e) {
                      // 실패하면 원래 상태로 복구
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
      },
    );
  }
}

class AppStyles {
  static const TextStyle title = TextStyle(fontWeight: FontWeight.w700, fontSize: 20);
  static const TextStyle cost = TextStyle(fontWeight: FontWeight.w700, fontSize: 36);
  static const TextStyle profit = TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: Colors.red);
}
