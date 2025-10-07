// lib/screens/watchlist/watchlist_view.dart (핵심 부분만)
import 'package:flutter/material.dart';
import 'package:stockapp/data/interestlist_api.dart';
import 'package:stockapp/data/recent_api.dart';
import 'package:stockapp/data/stock_detail_api.dart';
import 'package:stockapp/models/StockItemModel.dart';
import 'package:stockapp/models/stock.dart';
import '../../models/stock_brief.dart';
import '../../widgets/common/TopTabSelector.dart';
import '../../widgets/interest/WatchlistItem.dart';

class WatchlistView extends StatefulWidget {
  const WatchlistView({super.key});
  @override
  State<WatchlistView> createState() => _WatchlistViewState();
}

class _WatchlistViewState extends State<WatchlistView> {
  final _tabs = const ['관심', '최근'];
  int _selectedIndex = 0;
  final _pageController = PageController();

  final _api = InterestlistApi();
  final _recentApi = RecentApi();

  late Future<List<StockBrief>> _watchFuture;
  late Future<List<StockBrief>> _recentFuture;

  @override
  void initState() {
    super.initState();
    _watchFuture = _api.fetchWatchlist();
    _recentFuture = _recentApi.fetchRecent();
  }

  Future<void> _reloadCurrent() async {
    setState(() {
      if (_selectedIndex == 0) {
        _watchFuture = _api.fetchWatchlist();
      } else {
        _recentFuture = _recentApi.fetchRecent();
      }
    });
    await (_selectedIndex == 0 ? _watchFuture : _recentFuture);
  }

  void _onTabTap(int index) {
    setState(() => _selectedIndex = index);
    _pageController.animateToPage(index,
        duration: const Duration(milliseconds: 220), curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        TopTabSelector(tabs: _tabs, selectedIndex: _selectedIndex, onTap: _onTabTap),
        const SizedBox(height: 8),
        Expanded(
          child: PageView(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _selectedIndex = i),
            children: [
              _WatchlistListFuture(future: _watchFuture, onRefresh: _reloadCurrent),
              _WatchlistListFuture(future: _recentFuture, onRefresh: _reloadCurrent),
            ],
          ),
        ),
      ],
    );
  }
}

class _WatchlistListFuture extends StatefulWidget {
  final Future<List<StockBrief>> future;
  final Future<void> Function() onRefresh;
  const _WatchlistListFuture({required this.future, required this.onRefresh});

  @override
  State<_WatchlistListFuture> createState() => _WatchlistListFutureState();
}

class _WatchlistListFutureState extends State<_WatchlistListFuture> {
  final _detailApi = StockDetailApiService();
  final Map<int, Future<StockItem?>> _cache = {}; // ✅ 캐시

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<StockBrief>>(
      future: widget.future,
      builder: (context, snap) {
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        final items = snap.data!;

        return RefreshIndicator(
          onRefresh: widget.onRefresh,
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, i) {
              final s = items[i];
              _cache[s.id] ??= _detailApi.fetchStockDetail(s.id.toString()).then((resp) {
                return StockItem(
                  stockId: s.id,
                  name: s.name,
                  price: int.tryParse((resp.price ?? '').replaceAll(',', '')) ?? 0,
                  changeRate: double.tryParse((resp.changeRate ?? '').replaceAll('%', '')) ?? 0.0,
                  imageUrl: s.imageUrl,
                  rank: 0,
                );
              });

              return FutureBuilder<StockItem?>(
                future: _cache[s.id], // ✅ 캐싱된 Future 사용
                builder: (context, qSnap) {
                  final quote = qSnap.data;
                  return WatchlistItem(
                    stock: Stock(id: s.id, name: s.name, imageUrl: s.imageUrl),
                    quote: quote,
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
