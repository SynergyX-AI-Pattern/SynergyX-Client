import 'package:flutter/material.dart';
import 'package:interactive_chart/interactive_chart.dart';

import '../common/InfoCardGroup.dart';

class RecentBacktestResultCard extends StatelessWidget {
  final Map<String, dynamic> backtest;
  final List<CandleData> candles;
  final VoidCallback onChangeStock;
  final VoidCallback onTapDetail;
  final VoidCallback? onRunBacktest;

  const RecentBacktestResultCard({
    super.key,
    required this.backtest,
    required this.candles,
    required this.onChangeStock,
    required this.onTapDetail,
    this.onRunBacktest,
  });

  /// 퍼센트 값을 보기 좋게 포매팅
  String _formatPercent(dynamic value, {bool isRatio = false}) {
    if (value == null) return '0.00%';
    final numVal = (value is num) ? value : num.tryParse(value.toString()) ?? 0;
    final p = isRatio ? numVal * 100 : numVal;
    return '${p.toStringAsFixed(2)}%';
  }

  /// 카드 박스 공통 스타일
  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: const [
        BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '최근 백테스팅 결과',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              // 실행 날짜 표시
              Text(
                '실행한 날짜: ${backtest["executedAt"]}',
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const Spacer(),
              // 매칭 횟수 표시
              Text(
                '매칭 횟수: ${backtest["matchedCount"]}',
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // 종목 이미지
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(backtest['stockImage'] ?? ''),
              ),
              const SizedBox(width: 12),
              // 종목 이름
              Text(
                backtest['stockName'] ?? '',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              OutlinedButton(
                onPressed: onChangeStock,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black,
                  side: const BorderSide(color: Colors.black12),
                ),
                child: const Text('종목 바꾸기'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            // 캔들 차트 영역
            child: InteractiveChart(
              candles: candles,
              style: const ChartStyle(
                priceGainColor: Colors.red,
                priceLossColor: Colors.blue,
              ),
            ),
          ),
          Row(
            children: [
              // 시작 날짜 표시
              Text(
                '시작 날짜: ${backtest["startDate"]}',
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(width: 16),
              // 평균 수익률 표시
              Text(
                '수익률: ${_formatPercent(backtest["averageReturn"])}',
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const Spacer(),
              TextButton(
                onPressed: onTapDetail,
                style: TextButton.styleFrom(foregroundColor: Colors.black),
                child: const Text('더보기'),
              ),
            ],
          ),
          InfoCardGroup(
            rows: [
              {
                'label': '승률',
                'value': _formatPercent(backtest['winRate']),
              },
              {
                'label': '평균 수익률',
                'value': _formatPercent(backtest['averageReturn'], isRatio: true),
                'color': const Color(0xFF289BF6),
              },
              {
                'label': '최대 수익률',
                'value': _formatPercent(backtest['maxReturn']),
                'subValue': backtest['maxReturnDate'],
                'color': const Color(0xFF289BF6),
              },
            ],
          ),
          if (onRunBacktest != null)
            Center(
              child: ElevatedButton(
                onPressed: onRunBacktest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                ),
                child: const Text('다시 돌리기'),
              ),
            ),
        ],
      ),
    );
  }
}