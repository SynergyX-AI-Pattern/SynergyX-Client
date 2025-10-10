import 'package:flutter/material.dart';
import 'package:stockapp/models/pattern_apply.dart';
import 'package:stockapp/widgets/common/InfoCardGroup.dart';
import 'package:stockapp/screens/backtest/backtest_result_screen.dart';
import 'package:stockapp/widgets/common/backtest_candle_chart.dart';
import 'dart:math' as math;

class BacktestResultCard extends StatelessWidget {
  final BacktestResult result;

  const BacktestResultCard({super.key, required this.result});

  double _truncate(num v, int decimals) {
    final f = math.pow(10, decimals).toDouble();
    return (v * f).truncateToDouble() / f; // 소수점 2자리까지 출력
  }

  String _fmtPct(
    num v, {
    bool inputIsRatio = false, // true면 0.053 -> 5.3%
    int decimals = 2,
    bool round = true,
  }) {
    final p = (inputIsRatio ? v * 100 : v.toDouble());
    final d =
        round
            ? double.parse(p.toStringAsFixed(decimals))
            : _truncate(p, decimals);
    return '${d.toStringAsFixed(decimals)}%';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Column(
            children: [
              // 실행일, 매칭 횟수
              Row(
                children: [
                  Text('실행 날짜 : ', style: TextStyles.partName),
                  Text('${result.executedAt}', style: TextStyles.valueText),
                  const SizedBox(width: 10),
                  Text('매칭 횟수 : ', style: TextStyles.partName),
                  Text('${result.matchedCount}', style: TextStyles.valueText),
                ],
              ),
              const SizedBox(height: 12),

              // 백테스팅 캔들차트
              BacktestCandleChart(backtestId: result.backtestId),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 기간 + 더보기 버튼
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Row(
            children: [
              Text('기간 : ', style: TextStyles.partName),
              Text(
                '${result.startDate} ~ ${result.endDate}',
                style: TextStyles.valueText,
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  // 백테스트 상세 페이지로 이동
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder:
                          (_) => BacktestResultScreen(
                            result: result.toJson(), // ← Map으로 변환해서 전달
                          ),
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  '더보기',
                  style: TextStyle(color: Color(0xFF9D9D9D), fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        // 지표
        Transform.translate(
          offset: const Offset(0, -6),
          child: InfoCardGroup(
            rows: [
              {'label': '승률', 'value': _fmtPct(result.winRate, decimals: 1)},
              {
                'label': '평균 수익',
                'value': _fmtPct(result.averageReturn, decimals: 2),
                'color': const Color(0xFF1573FE),
              },
              {
                'label': '최대 수익',
                'value': _fmtPct(result.maxReturn, decimals: 2, round: false),
                'subValue': result.maxReturnDate,
                'color': const Color(0xFF1573FE),
              },
            ],
          ),
        ),
      ],
    );
  }
}

class TextStyles {
  static const TextStyle partName = TextStyle(
    color: Color(0xFF8198A5),
    fontSize: 14,
  );
  static const TextStyle valueText = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 13,
  );
}
