import 'package:flutter/material.dart';
import 'package:stockapp/screens/stock_detail_screen.dart';
import 'package:stockapp/models/StockItemModel.dart';
import 'package:stockapp/widgets/main/StockRankItem.dart';

class TopStocksScreen extends StatelessWidget {
  final List<StockItem> stockList;
  final String stockTitle;

  const TopStocksScreen({super.key, required this.stockList, required this.stockTitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(stockTitle, style: TextStyles.title,),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(13, 2, 15, 10),
        itemCount: stockList.length,
        itemBuilder: (context, index) {
          final stock = stockList[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DetailScreen(stock: stock), // stock 넘기기
                ),
              );
            },
            child: StockRankItem(stock: stock),
          );
        },
      ),
    );
  }
}


class TextStyles {
  static const TextStyle title = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 18,
  );

}