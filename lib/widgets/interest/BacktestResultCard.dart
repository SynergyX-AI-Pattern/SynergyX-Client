import 'package:flutter/material.dart';
import 'package:stockapp/models/pattern_apply.dart';
import 'package:stockapp/widgets/common/InfoCardGroup.dart';
import 'dart:math' as math;
import 'package:stockapp/widgets/common/app_button.dart';

class BacktestResultCard extends StatelessWidget {
  final BacktestResult result;
  const BacktestResultCard({required this.result});

  double _truncate(num v, int decimals) {
    final f = math.pow(10, decimals).toDouble();
    return (v * f).truncateToDouble() / f; // 소수점 2자리까지 출력
  }

  String _fmtPct(
      num v, {
        bool inputIsRatio = false, // true면 0.053 -> 5.3%
        int decimals = 2,
        bool round = true,    // false면 반올림 안 하고 자리수에서 자름(내림/절삭)
      }) {
    final p = (inputIsRatio ? v * 100 : v.toDouble());
    final d = round ? double.parse(p.toStringAsFixed(decimals))
        : _truncate(p, decimals);
    return '${d.toStringAsFixed(decimals)}%';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 실행일, 매칭 횟수
              Row(
                children: [
                  Text('실행 날짜 : ',
                      style: TextStyles.partName),
                  Text('${result.executedAt}', style: TextStyles.valueText,),
                  SizedBox(width: 10),
                  Text('매칭 횟수 : ', style: TextStyles.partName),
                  Text('${result.matchedCount}', style: TextStyles.valueText,),
                ],

              ),
              const SizedBox(height: 12),
              //패턴


              //기간
              Row(
                children: [
                  Text('기간 : ', style: TextStyles.partName,),
                  Text('${result.startDate} ~ ${result.endDate}', style: TextStyles.valueText,),
                  const Spacer(),
                  TextButton(
                      onPressed: () {},
                    style: TextButton.styleFrom(
                      minimumSize: Size.zero,
                      padding: EdgeInsets.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                      child: Text('더보기',
                        style: TextStyle(color: Color(0xFF9D9D9D), fontSize: 13),
                      ),
                  ),
                ],
              ),

              // 지표들
              InfoCardGroup(
                rows: [
                  {'label': '승률', 'value': _fmtPct(result.winRate, decimals: 1)},
                  {'label': '평균 수익', 'value': _fmtPct(result.averageReturn, decimals: 2, inputIsRatio: false), 'color': const Color(0xFF1573FE)},
                  {'label': '최대 수익', 'value': _fmtPct(result.maxReturn,   decimals: 2, round: false), 'subValue': result.maxReturnDate,'color': const Color(0xFF1573FE)},
                ],),

            ],
          )
    );

  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;
  const _Metric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(right: 10, bottom: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            const SizedBox(height: 4),
            Text(value,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class TextStyles {
  static const TextStyle partName = TextStyle(
      color: Color(0xFF8198A5),
      fontSize: 14
  );
  static const TextStyle valueText= TextStyle(
      fontWeight: FontWeight.w500,
      fontSize: 13
  );
}