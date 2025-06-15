import 'package:flutter/material.dart';
import 'package:stockapp/screens/stock_detail_screen.dart';
import 'package:stockapp/widgets/main/RecentStockList.dart';
import 'package:stockapp/widgets/main/topStock.dart';
import 'package:stockapp/widgets/common/searchBar.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  void _handleDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DetailScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Column(
                //mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  StockSerachBar(text: '종목 검색'),
                  SizedBox(height: 8),
                  Topstock(),
                  SizedBox(height: 8),
                  const RecentStockList()
                ],
              ),
            ),
          )
      ),
    );
  }
}