import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stockapp/screens/backtest/backtest_result_screen.dart';
import 'package:stockapp/data/backtest_api.dart';

import 'package:stockapp/widgets/backtest/backtest_result_chart.dart';
import 'package:stockapp/widgets/common/InfoCardGroup.dart';

// backtest_list_screen.dart
class BacktestListScreen extends StatefulWidget {
  final int? patternId;
  final int? backtestId;
  final bool showAll;

  const BacktestListScreen({
    super.key,
    this.patternId,
    this.backtestId,
    this.showAll = false,
  });

  @override
  State<BacktestListScreen> createState() => _BacktestListScreenState();
}

class _BacktestListScreenState extends State<BacktestListScreen> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = BacktestService.fetchBacktestList(
      // 전체 보기 모드에서는 패턴 필터를 제거하고 모든 백테스트를 요청한다.
      patternId: widget.showAll ? null : widget.patternId,
      backtestId: widget.backtestId,
    );
  }

  @override
  Widget build(BuildContext context) {
    // 현재 화면이 어떤 맥락인지에 따라 제목을 다르게 노출한다.
    final title = widget.showAll
        ? '전체 백테스트 목록'
        : widget.backtestId != null
        ? '패턴 백테스트 목록'
        : '백테스트 목록';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(title, style: const TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          if (widget.patternId != null && !widget.showAll)
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BacktestListScreen(
                      // 전체 보기는 패턴 제한 없이 전부를 보여준다.
                      patternId: widget.patternId,
                      showAll: true,
                    ),
                  ),
                );
              },
              child: const Text('전체 보기', style: TextStyle(color: Colors.black)),
            ),
        ],
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
                  final detail = await BacktestService.fetchBacktestResult(
                    item['backtestId'],
                    stockId: item['stockId'],
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

class _BacktestResultCard extends StatefulWidget {
  final Map<String, dynamic> summary;
  final VoidCallback onMore;
  final VoidCallback onRerun;

  const _BacktestResultCard({
    required this.summary,
    required this.onMore,
    required this.onRerun,
  });

  @override
  State<_BacktestResultCard> createState() => _BacktestResultCardState();
}

class _BacktestResultCardState extends State<_BacktestResultCard> {
  Map<String, dynamic>? _detail;

  @override
  void didUpdateWidget(covariant _BacktestResultCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!mapEquals(widget.summary, oldWidget.summary)) {
      setState(() {
        _detail = null;
      });
    }
  }

  /// result 키 하위에 존재하는 상세 데이터를 평평하게 정규화한다.
  Map<String, dynamic> _normalize(Map<String, dynamic> raw) {
    final result = raw['result'];
    if (result is Map) {
      return Map<String, dynamic>.from(result as Map);
    }
    return Map<String, dynamic>.from(raw);
  }

  /// 상세 데이터를 우선 적용하고, 없으면 요약 데이터를 사용한다.
  Map<String, dynamic> get _result => _normalize(_detail ?? widget.summary);

  /// 차트 위젯이 상세 데이터를 로드했을 때 상태를 갱신한다.
  void _handleDetailLoaded(Map<String, dynamic> detail) {
    setState(() {
      _detail = detail;
    });
  }

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
    if (value == null) return '0.00%';
    final numVal = (value is num) ? value : num.tryParse(value.toString()) ?? 0;
    final p = isRatio ? numVal : numVal;
    return '${p.toStringAsFixed(2)}%';
  }

  @override
  Widget build(BuildContext context) {
    final executedAt = widget.summary['executedAt'] ?? '';
    final matchedCount = widget.summary['matchedCount'] ?? 0;
    final stockImage = widget.summary['stockImage'] ?? '';
    final stockName = widget.summary['stockName'] ?? '';
    final startDate = widget.summary['startDate'] ?? '';
    final avgReturn = _result['averageReturn'];
    final winRate = _result['winRate'];
    final maxReturn = _result['maxReturn'];
    final maxReturnDt = _result['maxReturnDate'];

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
              Text(
                '실행한 날짜: $executedAt',
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const Spacer(),
              Text(
                '매칭 횟수: $matchedCount',
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: safeNetworkImage(stockImage),
                child: (stockImage == null || stockImage.toString().trim().isEmpty)
                    ? const Icon(Icons.image_not_supported, size: 18, color: Colors.grey)
                    : null,
              ),
              const SizedBox(width: 12),
              Text(
                stockName,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: BacktestHighlightChart(
              summary: widget.summary,
              onDetailLoaded: _handleDetailLoaded,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '시작 날짜: $startDate',
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(width: 16),
              Text(
                '수익률: ${_formatPercent(avgReturn)}',
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const Spacer(),
              TextButton(
                onPressed: widget.onMore,
                style: TextButton.styleFrom(foregroundColor: Colors.black),
                child: const Text('더보기'),
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
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: widget.onRerun,
              style: TextButton.styleFrom(foregroundColor: Colors.black),
              child: const Text('다시 실행'),
            ),
          ),
        ],
      ),
    );
  }
}