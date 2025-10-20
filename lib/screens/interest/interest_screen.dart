import 'package:flutter/material.dart';
import 'package:stockapp/data/watchlist_api.dart';
import 'package:stockapp/models/StockItemModel.dart';
import 'package:stockapp/screens/mypage_interest_screen.dart';
import 'package:stockapp/widgets/interest/WatchlistAppBarActions.dart';

final interestTabNotifier = ValueNotifier<int>(0);

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
    _watchlistFuture = _apiService.fetchWatchlist();
  }

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
        title: const Text(
          '관심종목',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
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
        ],
      ),
      body: SafeArea(
        child: ValueListenableBuilder<int>(
          valueListenable: interestTabNotifier,
          builder: (context, currentTabIndex, _) {
            return Column(
              children: [
                Expanded(
                  child: WatchlistView(initialIndex: currentTabIndex),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
