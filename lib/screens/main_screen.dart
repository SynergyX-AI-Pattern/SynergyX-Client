import 'package:flutter/material.dart';
import 'package:stockapp/widgets/main/RecentStockList.dart';
import 'package:stockapp/widgets/main/topStock.dart';
import 'package:stockapp/widgets/common/searchBar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  Future<void> _onRefresh() async {
    setState(() {}); // 단순히 rebuild
    await Future.delayed(const Duration(milliseconds: 500)); // 약간의 대기시간
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: RefreshIndicator(
          color: Colors.black,
          onRefresh: _onRefresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(), // 빈 화면에서도 스크롤 가능하게
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Column(
                children: [
                  const StockSerachBar(text: '종목 검색'),
                  const SizedBox(height: 8),
                  const Topstock(),
                  const SizedBox(height: 8),
                  const RecentStockList(),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
