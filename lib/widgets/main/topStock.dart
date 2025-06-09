import 'package:flutter/material.dart';
import 'package:stockapp/data/dummy/dummy_stock_data.dart';
import 'package:stockapp/models/StockItemModel.dart';
import 'package:stockapp/widgets/common/TopTabSelector.dart';
import 'package:stockapp/widgets/main/TopStockListCard.dart';

// 주식 종목 탑 네비게이션
class Topstock extends StatefulWidget {
  const Topstock({super.key});

  @override
  State<Topstock> createState() => _TopstockState();
}

class _TopstockState extends State<Topstock> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<StockItem> selectedList =
    _selectedTabIndex == 0 ? dummyStockItems : dummyAIStockItems;
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
        TopStockListCard(stockList: selectedList, title: selectedTitle,)
      ],
    );
  }
}
