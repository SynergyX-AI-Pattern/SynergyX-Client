import 'package:flutter/material.dart';
import 'package:stockapp/data/stock_api.dart';
import 'package:stockapp/widgets/search/SearchStockItem.dart';
import '../models/stock.dart';
import 'stock_detail_screen.dart';
import 'package:stockapp/screens/image_search_screen.dart';

class StockSearchPage extends StatefulWidget {
  final void Function(String stockCode)? onStockSelected;

  const StockSearchPage({super.key, this.onStockSelected});

  @override
  State<StockSearchPage> createState() => _StockSearchPageState();
}

class _StockSearchPageState extends State<StockSearchPage> {
  final TextEditingController _controller = TextEditingController();
  List<Stock> filtered = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onSearchChanged);
  }

  void _onSearchChanged() async {
    final input = _controller.text.trim();
    if (input.isEmpty) {
      setState(() => filtered = []);
      return;
    }

    setState(() => isLoading = true);
    try {
      final results = await fetchSearchedStocks(input);
      setState(() {
        filtered = results;
      });
    } catch (e) {
      print('검색 실패: $e');
      setState(() {
        filtered = [];
      });
    } finally {
      setState(() => isLoading = false);
    }
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
            // 상단 검색창
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
                          hintStyle: const TextStyle(
                            color: Color(0xFFAEAEAE),
                            fontWeight: FontWeight.w500,
                          ),
                          border: InputBorder.none,
                          prefixIcon: const Padding(
                            padding: EdgeInsets.only(left: 10, right: 10),
                            child: Icon(
                              Icons.search,
                              size: 26,
                              color: Color(0xFF767676),
                            ),
                          ),
                          prefixIconConstraints: const BoxConstraints(
                            minWidth: 40,
                            minHeight: 40,
                          ),
                          suffixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_controller.text.isNotEmpty)
                                IconButton(
                                  icon: const Icon(
                                    Icons.highlight_remove,
                                    size: 18,
                                  ),
                                  onPressed: () {
                                    _controller.clear();
                                    _onSearchChanged();
                                  },
                                  padding: const EdgeInsets.only(right: 0),
                                  constraints: const BoxConstraints(),
                                ),
                              IconButton(
                                icon: const Icon(
                                  Icons.image_search,
                                  color: Color(0xFF767676),
                                  size: 26,
                                ),
                                onPressed: () {
                                  Navigator.of(
                                    context,
                                    rootNavigator: false,
                                  ).push(
                                    MaterialPageRoute(
                                      builder: (_) => const ImageSearchScreen(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 11,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 검색 결과 리스트
            Expanded(
              child:
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : filtered.isEmpty
                      ? const Center(child: Text('검색 결과가 없습니다'))
                      : ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final stock = filtered[index];
                          return SearchStockItem(
                            stock: stock,
                            onTap: () {
                              //if (widget.onStockSelected != null) {
                              //     widget.onStockSelected!(stock.name); // 또는 stock.id
                              //    }
                              //    Navigator.push(
                              //    context,
                              //    MaterialPageRoute(
                              //    builder: (_) => DetailScreen()),
                              //    );
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
