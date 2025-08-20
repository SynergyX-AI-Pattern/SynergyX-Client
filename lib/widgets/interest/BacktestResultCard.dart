import 'package:flutter/material.dart';
import 'package:stockapp/models/pattern_apply.dart';
import 'package:stockapp/widgets/common/InfoCardGroup.dart';

class BacktestResultCard extends StatelessWidget {
  final BacktestResult result;
  const BacktestResultCard({required this.result});

  String _fmtPct(num v, {bool isRatio = false}) {
    final p = isRatio ? v * 100 : v;
    return '${p.toStringAsFixed(2)}%';
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
                  {'label': '승률', 'value': _fmtPct(result.winRate)},
                  {'label': '평균 수익', 'value': _fmtPct(result.averageReturn, isRatio: true), 'color': const Color(0xFF289BF6)},
                  {'label': '최대 수익', 'value': _fmtPct(result.maxReturn), 'subValue': result.maxReturnDate,'color': const Color(0xFF289BF6)},
                ],),

              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () {
                    // TODO: 재실행 API 있으면 호출 후 상단 RefreshIndicator로 갱신
                  },
                  label: const Text('다시 돌리기'),
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
