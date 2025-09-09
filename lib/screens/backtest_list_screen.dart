import 'package:flutter/material.dart';
import 'package:interactive_chart/interactive_chart.dart';
import 'package:stockapp/screens/backtest_result_screen.dart';
import 'package:stockapp/data/backtest_api.dart';

import 'package:stockapp/data/candle_api.dart';
import 'package:stockapp/widgets/common/InfoCardGroup.dart';

class BacktestListScreen extends StatefulWidget {
  final int? patternId; // 특정 패턴의 결과만 보고 싶을 때 사용

  /// [patternId]가 주어지면 해당 패턴의 백테스트만 조회한다.
  const BacktestListScreen({super.key, this.patternId});

  @override
  State<BacktestListScreen> createState() => _BacktestListScreenState();
}

class _BacktestListScreenState extends State<BacktestListScreen> {
  late Future<List<Map<String, dynamic>>> _future; // API 호출 결과

  @override
  void initState() {
    super.initState();
    _future = BacktestService.fetchBacktestList(patternId: widget.patternId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('백테스트 목록', style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('에러 발생: ${snapshot.error}'));
          }
          final list = snapshot.data ?? [];
          if (list.isEmpty) {
            return const Center(child: Text('백테스트 결과가 없습니다.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final item = list[index];
              return _BacktestResultCard(
                summary: item,
                onMore: () async {
                  final detail =
                  await BacktestService.fetchBacktestResult(
                    item['backtestId'],
                    stockId: item['stockId'], // 차트/이미지 조회를 위해 종목 ID 전달
                  );
                  if (!context.mounted) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BacktestResultScreen(result: detail),
                    ),
                  );
                },
                onRerun: () async {
                  // TODO: 백테스트 다시 실행 API 연결
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('백테스트 다시 실행 기능은 준비 중입니다.')),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
ImageProvider? safeNetworkImage(String? url) {
  if (url == null) return null;
  final trimmed = url.trim();
  if (trimmed.isEmpty) return null;
  return NetworkImage(trimmed);
}

class _BacktestResultCard extends StatelessWidget {
  final Map<String, dynamic> summary;
  final VoidCallback onMore;
  final VoidCallback onRerun;

  const _BacktestResultCard({
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
    final p = isRatio ? numVal * 100 : numVal;
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
                  style: const TextStyle(fontSize: 13, color: Colors.grey)),
              const Spacer(),
              Text("매칭 횟수: $matchedCount",
                  style: const TextStyle(fontSize: 13, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: safeNetworkImage(stockImage),
                child: (stockImage == null || stockImage.trim().isEmpty)
                    ? const Icon(Icons.image_not_supported, size: 18, color: Colors.grey)
                    : null,
              ),
              const SizedBox(width: 12),
              Text(stockName,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),

          const SizedBox(height: 16),

          SizedBox(
            height: 200,
            child: FutureBuilder<List<CandleData>>(
              future: fetchCandles(
                stockId: stockId.isEmpty ? "1" : stockId,
                interval: "1D",
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "캔들 데이터 불러오기 실패: ${snapshot.error}",
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                final candles = snapshot.data ?? [];
                if (candles.isEmpty) {
                  return const Center(
                      child: Text("캔들 데이터 없음", style: TextStyle(color: Colors.grey)));
                }
                return InteractiveChart(
                  candles: candles,
                  style: const ChartStyle(
                    priceGainColor: Colors.red,
                    priceLossColor: Colors.blue,
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              Text("시작 날짜: $startDate",
                  style: const TextStyle(fontSize: 13, color: Colors.grey)),
              const SizedBox(width: 16),
              Text("수익률: ${_formatPercent(avgReturn)}",
                  style: const TextStyle(fontSize: 13, color: Colors.grey)),
              const Spacer(),
              TextButton(
                onPressed: onMore, // 상세 페이지 이동
                style: TextButton.styleFrom(foregroundColor: Colors.black),
                child: const Text("더보기"),
              ),
            ],
          ),

          InfoCardGroup(
            rows: [
              {'label': '승률', 'value': _formatPercent(winRate)},
              {
                'label': '평균 수익률',
                'value': _formatPercent(avgReturn, isRatio: true),
                'color': const Color(0xFF289BF6)
              },
              {
                'label': '최대 수익률',
                'value': _formatPercent(maxReturn),
                'subValue': maxReturnDt,
                'color': const Color(0xFF289BF6)
              },
            ],
          ),
        ],
      ),
    );
  }
}
