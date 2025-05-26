import 'package:flutter/material.dart';

class StockSearchPage extends StatefulWidget {
  // This field is no longer used directly since selection is returned via Navigator
  final void Function(String stockCode)? onStockSelected;

  const StockSearchPage({super.key, this.onStockSelected});

  @override
  State<StockSearchPage> createState() => _StockSearchPageState();
}

class _StockSearchPageState extends State<StockSearchPage> {
  final TextEditingController _controller = TextEditingController();
  final List<String> allStocks = [
    'AAPL - Apple Inc.',
    'GOOGL - Alphabet Inc.',
    'TSLA - Tesla Inc.',
    'NFLX - Netflix Inc.',
    'FB - Facebook Inc.',
    'MSFT - Microsoft Corp.',
    'NVDA - NVIDIA Corp.',
  ];

  List<String> filtered = [];

  @override
  void initState() {
    super.initState();
    filtered = allStocks;
    _controller.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {
      filtered = allStocks
          .where((s) => s.toLowerCase().contains(_controller.text.toLowerCase()))
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
    return Scaffold(
      appBar: AppBar(title: const Text('종목 검색 및 선택')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: '주식 이름 또는 코드 입력',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final item = filtered[index];
                final stock = item.split(' - ').first;
                return ListTile(
                  title: Text(item),
                  onTap: () {
                    if (widget.onStockSelected != null) widget.onStockSelected!(stock);
                    Navigator.pop(context, stock);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

