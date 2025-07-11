import 'package:flutter/material.dart';
import 'package:stockapp/data/stock_detail_api.dart';
import 'package:stockapp/models/stock_detail_model.dart';
import 'package:stockapp/widgets/common/TopTabSelector.dart';
import 'package:stockapp/widgets/common/InfoCardGroup.dart';

class StockDetail extends StatefulWidget {
  final String stockId;

  const StockDetail({super.key, required this.stockId});

  @override
  State<StockDetail> createState() => _StockDetailScreenState();
}

class _StockDetailScreenState extends State<StockDetail> {
  int _selectedTabIndex = 0;
  late Future<StockDetailResponse> _stockDetailFuture;
  final StockDetailApiService _apiService = StockDetailApiService();

  @override
  void initState() {
    super.initState();
    _stockDetailFuture = _apiService.fetchStockDetail(widget.stockId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<StockDetailResponse>(
      future: _stockDetailFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('에러 발생: ${snapshot.error}'));
        }

        final data = snapshot.data!;

        return Column(
          children: [
            TopTabSelector(
              tabs: const ['AI 예측', '재무정보'],
              selectedIndex: _selectedTabIndex,
              onTap: (index) {
                setState(() {
                  _selectedTabIndex = index;
                });
              },
            ),
            Expanded(
              child: _selectedTabIndex == 0
                  ? AIPredictionView(prediction: data.prediction, currentPrice: data.price)
                  : FinancialInfoView(financials: data.financials),
            ),
          ],
        );
      },
    );
  }
}

class AIPredictionView extends StatelessWidget {
  final Prediction prediction;
  final String currentPrice;

  const AIPredictionView({
    super.key,
    required this.prediction,
    required this.currentPrice,
  });

  @override
  Widget build(BuildContext context) {
    return InfoCardGroup(
      title: 'AI 예측 주가',
      rows: [
        {'label': '현재가', 'value': currentPrice, 'color': const Color(0xFFF99F01)},
        {'label': '상한 예측가', 'value': prediction.upperBound, 'color': const Color(0xFFEC221F)},
        {'label': '하한 예측가', 'value': prediction.lowerBound, 'color': const Color(0xFF289BF6)},
        {'label': '적정 매도 가격', 'value': prediction.sellPrice},
        {'label': '적정 매수 가격', 'value': prediction.buyPrice},
        {'label': '예측 범위', 'value': prediction.targetRange},
      ],
    );
  }
}

class FinancialInfoView extends StatelessWidget {
  final Financials financials;

  const FinancialInfoView({super.key, required this.financials});

  @override
  Widget build(BuildContext context) {
    return InfoCardGroup(
      title: '재무 정보',
      rows: [
        {'label': '시가총액', 'value': financials.marketCap},
        {'label': '배당수익률', 'value': financials.dividendYield ?? '2.56%'},
        {'label': 'ROE', 'value': financials.roe},
        {'label': 'PBR', 'value': financials.pbr},
        {'label': 'PER', 'value': financials.per},
        {'label': 'PSR', 'value': financials.psr},
      ],
    );
  }
}
