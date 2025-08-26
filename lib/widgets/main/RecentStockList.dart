import 'package:flutter/material.dart';
import 'package:stockapp/data/recent_api.dart';
import 'package:stockapp/models/stock_brief.dart';
import 'package:stockapp/widgets/main/recent_stock_tile.dart';

class RecentStockList extends StatefulWidget {
  const RecentStockList({super.key});

  @override
  State<RecentStockList> createState() => _RecentStockListState();
}

class _RecentStockListState extends State<RecentStockList> {
  final _api = RecentApi();
  late Future<List<StockBrief>> _future;

  @override
  void initState() {
    super.initState();
    _future = _api.fetchRecent();
  }

  Future<void> _reload() async {
    setState(() => _future = _api.fetchRecent());
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<StockBrief>>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: SizedBox(height: 56, child: Center(child: CircularProgressIndicator())),
          );
        }
        if (snap.hasError) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: TextButton.icon(
              onPressed: _reload,
              icon: const Icon(Icons.refresh),
              label: Text('최근 조회 종목을 불러오지 못했습니다: ${snap.error}'),
            ),
          );
        }

        // 전체 결과에서 최신순 3개만 사용 (API가 최신순으로 내려준다는 가정)
        final all = snap.data ?? const <StockBrief>[];
        final items = all.take(3).toList(); // ← 여기!

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 16, right: 16, bottom: 8),
              child: Text('최근 조회 종목',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20)),
            ),
            if (items.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('최근 조회한 종목이 없습니다.',
                      style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFFAEAEAE))),
                ),
              )
            else
              ...List.generate(items.length, (i) {
                final s = items[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                  child: Column(
                    children: [
                      RecentStockTile(
                        stock: s,
                        onTap: () {
                          // TODO: 상세 이동
                        },
                      ),
                    ],
                  ),
                );
              }),
          ],
        );
      },
    );
  }
}
