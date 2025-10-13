import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'package:stockapp/widgets/backtest/backtest_result_chart.dart';
import '../common/InfoCardGroup.dart';

class RecentBacktestResultCard extends StatefulWidget {
  final Map<String, dynamic> backtest;
  final VoidCallback onChangeStock;
  final VoidCallback onTapDetail;
  final VoidCallback? onRunBacktest;

  const RecentBacktestResultCard({
    super.key,
    required this.backtest,
    required this.onChangeStock,
    required this.onTapDetail,
    this.onRunBacktest,
  });

  @override
  State<RecentBacktestResultCard> createState() => _RecentBacktestResultCardState();
}

class _RecentBacktestResultCardState extends State<RecentBacktestResultCard> {
  Map<String, dynamic>? _detail;

  @override
  void didUpdateWidget(covariant RecentBacktestResultCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 백테스트 결과가 갱신되면 차트를 다시 그리도록 처리
    if (!mapEquals(widget.backtest, oldWidget.backtest)) {
      setState(() {
        _detail = null;
      });
    }
  }

  /// 백테스트 응답에서 핵심 result 맵을 추출한다.
  Map<String, dynamic> _normalize(Map<String, dynamic> raw) {
    final result = raw['result'];
    if (result is Map) {
      return Map<String, dynamic>.from(result as Map);
    }
    return Map<String, dynamic>.from(raw);
  }

  /// 현재 보유 중인 상세/요약 데이터를 하나의 맵으로 정규화한다.
  Map<String, dynamic> get _result => _normalize(_detail ?? widget.backtest);

  /// 차트 위젯이 상세 데이터를 불러왔을 때 콜백으로 받아 저장한다.
  void _handleDetailLoaded(Map<String, dynamic> detail) {
    setState(() {
      _detail = detail;
    });
  }

  /// 퍼센트 값을 보기 좋게 포매팅한다.
  /// - isRatio=true 인 경우 0.123 -> "12.30%"
  String _formatPercent(dynamic value, {bool isRatio = false}) {
    if (value == null) return '0.00%';
    final numVal = (value is num) ? value : num.tryParse(value.toString()) ?? 0;
    final p = isRatio ? (numVal * 100) : numVal;
    return '${p.toStringAsFixed(2)}%';
  }

  /// 카드 박스 공통 스타일을 정의한다.
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
    final String stockName = (widget.backtest['stockName'] ?? '').toString();
    final String? stockImage = widget.backtest['stockImage']?.toString();

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
                '실행한 날짜: ${widget.backtest["executedAt"]}',
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const Spacer(),
              Text(
                '매칭 횟수: ${widget.backtest["matchedCount"]}',
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: (stockImage != null && stockImage.isNotEmpty)
                    ? NetworkImage(stockImage)
                    : null,
                child: (stockImage == null || stockImage.isEmpty)
                    ? const Icon(Icons.image_not_supported, color: Colors.grey, size: 18)
                    : null,
              ),
              const SizedBox(width: 12),
              Text(
                stockName,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              OutlinedButton(
                onPressed: widget.onChangeStock,
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
            child: BacktestHighlightChart(
              summary: widget.backtest,
              onDetailLoaded: _handleDetailLoaded,
            ),
          ),
          Row(
            children: [
              Text(
                '시작 날짜: ${widget.backtest["startDate"]}',
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(width: 16),
              Text(
                '수익률: ${_formatPercent(_result["averageReturn"], isRatio: true)}',
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const Spacer(),
              TextButton(
                onPressed: widget.onTapDetail,
                style: TextButton.styleFrom(foregroundColor: Colors.black),
                child: const Text('더보기'),
              ),
            ],
          ),
          InfoCardGroup(
            rows: [
              {
                'label': '승률',
                'value': _formatPercent(_result['winRate'], isRatio: true),
              },
              {
                'label': '평균 수익률',
                'value': _formatPercent(_result['averageReturn'], isRatio: true),
                'color': const Color(0xFF289BF6),
              },
              {
                'label': '최대 수익률',
                'value': _formatPercent(_result['maxReturn'], isRatio: true),
                'subValue': _result['maxReturnDate'],
                'color': const Color(0xFF289BF6),
              },
            ],
          ),
          if (widget.onRunBacktest != null)
            Center(
              child: ElevatedButton(
                onPressed: widget.onRunBacktest,
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