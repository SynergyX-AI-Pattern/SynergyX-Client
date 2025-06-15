import 'package:flutter/material.dart';
import 'package:stockapp/models/stock.dart';
import 'package:stockapp/screens/stock_detail_screen.dart';
import 'package:stockapp/widgets/search/SearchStockItem.dart';

class StockSearchPage extends StatefulWidget {
  final void Function(String stockCode)? onStockSelected;

  const StockSearchPage({super.key, this.onStockSelected});

  @override
  State<StockSearchPage> createState() => _StockSearchPageState();
}

class _StockSearchPageState extends State<StockSearchPage> {
  final TextEditingController _controller = TextEditingController();

  final List<Stock> allStocks = [
    Stock(name: '삼성전자', symbol: '005930', price: 78200, changePercent: 1.2),
    Stock(name: '삼성바이오로직스', symbol: '207940', price: 789000, changePercent: -0.8),
    Stock(name: '삼성중공업', symbol: '010140', price: 6820, changePercent: 0.3),
    Stock(name: '삼성SDI', symbol: '006400', price: 582000, changePercent: -1.5),
    Stock(name: '삼성전기', symbol: '009150', price: 148000, changePercent: 0.9),
    Stock(name: '삼성화재', symbol: '000810', price: 248500, changePercent: -0.4),
  ];

  List<Stock> filtered = [];

  @override
  void initState() {
    super.initState();
    filtered = allStocks;
    _controller.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final input = _controller.text.toLowerCase();
    setState(() {
      filtered = allStocks
          .where((s) =>
      s.name.toLowerCase().contains(input) ||
          s.symbol.toLowerCase().contains(input))
          .toList();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            // Top Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(1, 10, 10, 10),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: '종목 검색',
                          hintStyle: TextStyle(color: Color(0xFFAEAEAE), fontWeight: FontWeight.w500),
                          border: InputBorder.none,
                          prefixIcon: Padding(
                            padding: const EdgeInsets.only(left: 10), // ← 왼쪽 padding만 적용
                            child: Icon(Icons.search, size: 26, color: Color(0xFF767676)),
                          ),
                          prefixIconConstraints: BoxConstraints(
                            minWidth: 40,  // 아이콘이 너무 넓게 차지하지 않도록 최소값 설정
                            minHeight: 40,
                          ),
                          suffixIcon: _controller.text.isNotEmpty
                              ? IconButton(
                            icon: const Icon(Icons.highlight_remove, size: 18),
                            onPressed: () {
                              _controller.clear();
                              _onSearchChanged();
                            },
                          )
                              : null,
                          contentPadding: const EdgeInsets.symmetric(vertical: 11),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 검색 결과 리스트
            Expanded(
              child: ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final stock = filtered[index];
                  return SearchStockItem(
                    stock: stock,
                    onTap: () {
                      if (widget.onStockSelected != null) {
                        widget.onStockSelected!(stock.symbol);
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => DetailScreen()),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
