import 'package:flutter/material.dart';
import 'package:stockapp/data/watchlist_api.dart';
import 'package:stockapp/models/StockItemModel.dart';
import 'package:stockapp/widgets/main/StockItems.dart';
import 'stock_detail_screen.dart';

class InterestScreen extends StatefulWidget {
  const InterestScreen({super.key});

  @override
  State<InterestScreen> createState() => _InterestScreenState();
}

class _InterestScreenState extends State<InterestScreen> {
  final WatchlistApiService _apiService = WatchlistApiService();
  // 관심종목 목록을 불러오는 Future
  late Future<List<StockItem>> _watchlistFuture;

  @override
  void initState() {
    super.initState();
    // 화면이 생성될 때 관심종목 목록을 미리 불러옴
    _watchlistFuture = _apiService.fetchWatchlist();
  }

  /// 당겨서 새로고침 시 호출되는 메서드
  Future<void> _reload() async {
    final result = await _apiService.fetchWatchlist();
    setState(() {
      _watchlistFuture = Future.value(result);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('관심종목'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        centerTitle: true,
      ),
      // 관심종목 데이터를 비동기적으로 가져와 화면에 표시
      body: FutureBuilder<List<StockItem>>(
        future: _watchlistFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('오류 발생: ${snapshot.error}'));
          }
          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return const Center(child: Text('관심종목이 없습니다'));
          }
          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final stock = items[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailScreen(stock: stock),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Row(
                      children: [
                        Expanded(child: StockItems(stock: stock)),
                        // 하트 아이콘을 눌러 관심목록에서 제거할 수 있음
                        IconButton(
                          icon: const Icon(Icons.favorite, color: Colors.red),
                          onPressed: () async {
                            await _apiService.removeFromWatchlist(stock.stockId.toString());
                            _reload();
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}