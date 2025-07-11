import 'package:flutter/material.dart';
import 'package:stockapp/models/StockItemModel.dart';
import 'package:stockapp/widgets/common/TopTabSelector.dart';
import 'package:stockapp/widgets/main/TopStockListCard.dart';
import 'package:stockapp/data/stock_top_api.dart';

class Topstock extends StatefulWidget {
  const Topstock({super.key});

  @override
  State<Topstock> createState() => _TopstockState();
}

class _TopstockState extends State<Topstock> {
  final StockApiService _apiService = StockApiService();

  int _selectedTabIndex = 0;
  late Future<List<StockItem>> _topStockFuture;
  late Future<List<StockItem>> _aiTopStockFuture;

  @override
  void initState() {
    super.initState();
    _topStockFuture = _apiService.fetchTopStocks();
    _aiTopStockFuture = _apiService.fetchAiTopStocks();
  }

  @override
  Widget build(BuildContext context) {
    final String selectedTitle =
    _selectedTabIndex == 0 ? 'Top 20 종목' : 'AI Top 20 종목';

    return Column(
      children: [
        TopTabSelector(
          tabs: const ['Top 20 종목', 'AI Top 20 종목'],
          selectedIndex: _selectedTabIndex,
          onTap: (index) {
            setState(() {
              _selectedTabIndex = index;
            });
          },
        ),
        FutureBuilder<List<StockItem>>(
          future: _selectedTabIndex == 0
              ? _topStockFuture
              : _aiTopStockFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Text('데이터를 불러오는 데 실패했습니다.'),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(20),
                child: Text('데이터가 없습니다.'),
              );
            }

            return TopStockListCard(
              stockList: snapshot.data!,
              title: selectedTitle,
            );
          },
        ),
      ],
    );
  }
}
