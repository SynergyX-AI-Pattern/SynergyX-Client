import 'package:flutter/material.dart';
import 'package:stockapp/models/pattern_apply.dart';
import 'package:stockapp/widgets/common/InfoCardGroup.dart';
import 'dart:math' as math;

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
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 기간/실행일
              Text('기간 ${result.startDate} ~ ${result.endDate}'),
              Row(
                children: [
                  Text('실행 날짜 ${result.executedAt}',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                  const Spacer(),
                  Text('매칭 횟수 : ${result.matchedCount}'),
                ],
              ),
              const SizedBox(height: 12),

              // 지표들
              InfoCardGroup(
                rows: [
                  {'label': '승률', 'value': _fmtPct(result.winRate, decimals: 1)},
                  {'label': '평균 수익', 'value': _fmtPct(result.averageReturn, decimals: 2, inputIsRatio: false), 'color': const Color(0xFF289BF6)},
                  {'label': '최대 수익', 'value': _fmtPct(result.maxReturn,   decimals: 2, round: false), 'subValue': result.maxReturnDate,'color': const Color(0xFF289BF6)},
                ],),

              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: 재실행 API 있으면 호출 후 상단 RefreshIndicator로 갱신
                  },
                  style:  ElevatedButton.styleFrom(
                // 메인 컬러
                // primary: Colors.red, // Deprecated
                // 텍스트색상, ripple컬러
                foregroundColor: Colors.white,
                  // 버튼 배경 색
                  backgroundColor: Colors.black,
                  textStyle:
                  TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
                  // 글자 주변에 적용
                  padding: EdgeInsets.all(12),
                  // 테두리 설정
                  side: BorderSide( color: Colors.black, width: 1),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)
                  ),
                ),
                  child: const Text('다시 돌리기'),
                ),
              ),
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
