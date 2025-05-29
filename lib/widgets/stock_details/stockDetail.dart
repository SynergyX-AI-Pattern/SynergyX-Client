import 'package:flutter/material.dart';
import 'package:stockapp/widgets/common/TopTabSelector.dart';
import 'package:stockapp/widgets/common/InfoCardGroup.dart';


class StockDetail extends StatefulWidget {
  const StockDetail({super.key});

  @override
  State<StockDetail> createState() => _StockDetailScreenState();
}

class _StockDetailScreenState extends State<StockDetail> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
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
              ? const AIPredictionView()
              : const FinancialInfoView(),
        ),
      ],
    );
  }
}

// AI 예측 탭 내용
class AIPredictionView extends StatelessWidget {
  const AIPredictionView({super.key});

  @override
  Widget build(BuildContext context) {
    return InfoCardGroup(
      title: 'AI 예측 주가',
      rows: const [
        {'label': '현재가', 'value': '54,300', 'color': Color(0xFFF99F01)},
        {'label': '상한 예측가', 'value': '63,000', 'color': Color(0xFFEC221F)},
        {'label': '하한 예측가', 'value': '53,100', 'color': Color(0xFF289BF6)},
        {'label': '적정 매도 가격', 'value': '62,500'},
        {'label': '적정 매수 가격', 'value': '52,900'},
        {'label': '예측 범위', 'value': '20일 이내'},
      ],
    );
  }
}

// 재무정보 탭 내용
class FinancialInfoView extends StatelessWidget {
  const FinancialInfoView({super.key});

  @override
  Widget build(BuildContext context) {
    return InfoCardGroup(
      title: '재무 정보',
      rows: const [
        {'label': '시가총액', 'value': '372.1조원'},
        {'label': '배당수익률', 'value': '2.56%'},
        {'label': 'ROE', 'value': '9.0%'},
        {'label': 'PBR', 'value': '1.0배'},
        {'label': 'PER', 'value': '11.3배'},
        {'label': 'PSR', 'value': '1.3배'},

      ],
    );
  }
}

