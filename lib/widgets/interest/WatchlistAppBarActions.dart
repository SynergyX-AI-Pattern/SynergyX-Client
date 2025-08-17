// lib/screens/watchlist/watchlist_view.dart (핵심 부분만)
import 'package:flutter/material.dart';
import 'package:stockapp/data/interestlist_api.dart';
import 'package:stockapp/data/recent_api.dart';
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

class _WatchlistListFuture extends StatelessWidget {
  final Future<List<StockBrief>> future;
  final Future<void> Function() onRefresh;
  const _WatchlistListFuture({required this.future, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<StockBrief>>(
      future: future,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(
            child: TextButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
              label: Text('불러오기 실패: ${snap.error}'),
            ),
          );
        }
        final items = snap.data ?? const <StockBrief>[];
        return RefreshIndicator(
          onRefresh: onRefresh,
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: items.length,
            itemBuilder: (context, i) {
              final s = items[i];
              return WatchlistItem(
                stock: Stock(id: s.id, name: s.name, imageUrl: s.imageUrl),
                onTap: () {},
              );
            },
          ),
        );
      },
    );
  }
}
