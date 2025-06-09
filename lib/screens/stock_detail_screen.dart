import 'package:flutter/material.dart';
import 'package:stockapp/models/StockItemModel.dart';
import 'package:stockapp/widgets/stock_details/StockChart.dart';
import 'package:stockapp/widgets/stock_details/stockDetail.dart';
import 'package:stockapp/widgets/stock_details/stockName.dart';

class DetailScreen extends StatelessWidget {
  final StockItem? stock;

  const DetailScreen({super.key, this.stock});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          StockName(),
          Expanded(child: CandlestickChart()),
          Expanded(child: StockDetail()),
        ],
      ),
    );
  }
}
