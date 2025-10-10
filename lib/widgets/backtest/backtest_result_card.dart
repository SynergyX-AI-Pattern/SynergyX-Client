import 'package:flutter/material.dart';

/// 네트워크 이미지 주소가 비어있는 경우를 안전하게 처리하기 위한 헬퍼 함수.
ImageProvider? safeNetworkImage(String? url) {
  if (url == null) return null;
  final trimmed = url.trim();
  if (trimmed.isEmpty) return null;
  return NetworkImage(trimmed);
}

/// 백테스트 결과를 리스트 형태로 노출하기 위한 공용 카드 위젯.
class BacktestResultSummaryCard extends StatelessWidget {
  final Map<String, dynamic> summary;
  final VoidCallback onMore;
  final VoidCallback onRerun;

  const BacktestResultSummaryCard({
    super.key,
    required this.summary,
    required this.onMore,
    required this.onRerun,
  });

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: const [
        BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
      ],
    );
  }

  String _formatPercent(dynamic value, {bool isRatio = false}) {
    if (value == null) return "0.00%";
    final numVal = (value is num) ? value : num.tryParse(value.toString()) ?? 0;
    final p = isRatio ? numVal : numVal;
    return "${p.toStringAsFixed(2)}%";
  }

  @override
  Widget build(BuildContext context) {
    final executedAt = summary['executedAt'] ?? '';
    final matchedCount = summary['matchedCount'] ?? 0;
    final stockImage = summary['stockImage'] ?? '';
    final stockName = summary['stockName'] ?? '';
    final stockId =
    (summary['stockId'] ?? summary['symbol'] ?? '').toString();
    final startDate = summary['startDate'] ?? '';
    final avgReturn = summary['averageReturn'];
    final winRate = summary['winRate'];
    final maxReturn = summary['maxReturn'];
    final maxReturnDt = summary['maxReturnDate'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("최근 백테스팅 결과",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),

          Row(
            children: [
              Text("실행한 날짜: $executedAt",
                  style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 16),
              Text("매칭된 종목 수: $matchedCount",
                  style: const TextStyle(fontSize: 14)),
            ],
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              CircleAvatar(
                backgroundImage: safeNetworkImage(stockImage),
                child: stockImage == ''
                    ? Text(stockName.isNotEmpty ? stockName[0] : '?')
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(stockName,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('종목 ID: $stockId',
                        style: const TextStyle(fontSize: 14)),
                    Text('시작일: $startDate',
                        style: const TextStyle(fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('평균 수익률',
                      style: TextStyle(fontSize: 14, color: Colors.grey)),
                  Text(_formatPercent(avgReturn),
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('승률',
                      style: TextStyle(fontSize: 14, color: Colors.grey)),
                  Text(_formatPercent(winRate, isRatio: true),
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('최대 수익률',
                      style: TextStyle(fontSize: 14, color: Colors.grey)),
                  Text(_formatPercent(maxReturn),
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  if (maxReturnDt != null)
                    Text('기록일: $maxReturnDt',
                        style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: onMore,
                child:
                const Text('자세히 보기', style: TextStyle(color: Colors.blue)),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: onRerun,
                child: const Text('다시 실행'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}