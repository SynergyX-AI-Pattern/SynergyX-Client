import 'package:flutter/material.dart';
import 'package:stockapp/data/interestlist_api.dart';
import 'package:stockapp/data/recent_api.dart';
import '../../models/stock_brief.dart';
import '../../widgets/common/TopTabSelector.dart';
import '../../widgets/interest/WatchlistItem.dart';
import '../../services/watchlist_event.dart';

class WatchlistView extends StatefulWidget {
  final int initialIndex;
  const WatchlistView({super.key, this.initialIndex = 0});

  @override
  State<WatchlistView> createState() => _WatchlistViewState();
}

class _WatchlistViewState extends State<WatchlistView> {
  final _tabs = const ['관심', '최근'];
  late int _selectedIndex;
  late final PageController _pageController;

  final _api = InterestlistApi();
  final _recentApi = RecentApi();

  late Future<List<StockBrief>> _watchFuture;
  late Future<List<StockBrief>> _recentFuture;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _selectedIndex);
    _watchFuture = _api.fetchWatchlist();
    _recentFuture = _recentApi.fetchRecent();


    // 관심종목 변경 시 자동 새로고침
    watchlistChangedNotifier.addListener(() {
      if (watchlistChangedNotifier.value) {
        setState(() {
          _watchFuture = _api.fetchWatchlist();
        });
        watchlistChangedNotifier.value = false;
      }
    });
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
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
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
        TopTabSelector(
          tabs: _tabs,
          selectedIndex: _selectedIndex,
          onTap: _onTabTap,
        ),
        const SizedBox(height: 8),
        Expanded(
          child: PageView(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _selectedIndex = i),
            children: [
              _WatchlistListFuture(
                future: _watchFuture,
                onRefresh: _reloadCurrent,
              ),
              _WatchlistListFuture(
                future: _recentFuture,
                onRefresh: _reloadCurrent,
              ),
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
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<StockBrief>>(
      future: widget.future,
      builder: (context, snap) {
        if (!snap.hasData)
          return const Center(child: CircularProgressIndicator());
        final items = snap.data!;

        return RefreshIndicator(
          onRefresh: widget.onRefresh,
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, i) {
              final s = items[i];
              return WatchlistItem(stock: s);
            },
          ),
        );
      },
    );
  }
}
