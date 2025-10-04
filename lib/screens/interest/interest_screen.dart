import 'package:flutter/material.dart';
import 'package:stockapp/data/watchlist_api.dart';
import 'package:stockapp/models/StockItemModel.dart';
import 'package:stockapp/screens/mypage_interest_screen.dart';
import 'package:stockapp/widgets/interest/WatchlistAppBarActions.dart';

class InterestScreen extends StatefulWidget {
  const InterestScreen({super.key});

  @override
  State<InterestScreen> createState() => _InterestScreenState();
}

class _InterestScreenState extends State<InterestScreen> {
  final WatchlistApiService _apiService = WatchlistApiService();

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
        title: const Text('관심종목',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const WatchlistEditPage(),
                ),
              );
            },
            icon: const Icon(Icons.settings),
          ),
          IconButton(onPressed: () {/* 추가 */}, icon: const Icon(Icons.add)),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: const [
            Expanded(
              child: WatchlistView(),
            ),
          ],
        ),
      ),
    );
  }
}