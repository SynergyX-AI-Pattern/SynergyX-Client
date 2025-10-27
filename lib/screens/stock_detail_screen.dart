import 'package:flutter/material.dart';
import 'package:stockapp/models/StockItemModel.dart';
import 'package:stockapp/models/stock_detail_model.dart';
import 'package:stockapp/widgets/stock_details/StockChart.dart';
import 'package:stockapp/widgets/stock_details/stockDetail.dart';
import 'package:stockapp/widgets/stock_details/stockName.dart';
import 'package:stockapp/data/stock_detail_api.dart';

class DetailScreen extends StatefulWidget {
  final StockItem stock;

  const DetailScreen({super.key, required this.stock});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Future<StockDetailResponse> _stockDetailFuture;
  final _apiService = StockDetailApiService();

  @override
  void initState() {
    super.initState();
    _stockDetailFuture =
        _apiService.fetchStockDetail(widget.stock.stockId.toString());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<StockDetailResponse>(
      future: _stockDetailFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('에러 발생: ${snapshot.error}')),
          );
        }

        final detail = snapshot.data!;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  StockName(
                    detail: detail,
                    stockId: widget.stock.stockId.toString(),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.4,
                    child: CandlestickChart(
                      stockId: widget.stock.stockId.toString(),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.4,
                    child: StockDetail(detail: detail),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
