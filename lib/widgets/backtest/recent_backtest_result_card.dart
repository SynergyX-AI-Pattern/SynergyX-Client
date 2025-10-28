import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'package:stockapp/widgets/backtest/backtest_result_chart.dart';
import 'package:stockapp/widgets/common/app_button.dart';
import 'package:stockapp/widgets/common/dialog/info_dialog.dart';
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
  State<RecentBacktestResultCard> createState() =>
      _RecentBacktestResultCardState();
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
  String _formatPercent(dynamic value) {
    if (value == null) return '0.00%';
    final numVal = (value is num) ? value : num.tryParse(value.toString()) ?? 0;
    return '${numVal.toStringAsFixed(2)}%';
  }

  @override
  Widget build(BuildContext context) {
    final String stockName = (widget.backtest['stockName'] ?? '').toString();
    final String? stockImage = widget.backtest['stockImage']?.toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              '최근 백테스팅 결과',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
            ),
            SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => const InfoDialog(
                      title: '백테스팅이란?',
                      description:
                      '내 전략 패턴이 실제 투자에 도움이 되는지를 \n과거 주가 데이터를 기반으로 검증하는 기능입니다.\n\n'
                          '패턴이 일어난 구간의 수익률, 승률, 최대 수익일 등을 통해 패턴의 신뢰도를 확인할 수 있습니다.'
                  ),
                );
              },
              child: const Icon(Icons.info_outline, size: 20, color: Colors.grey),
            ),
          ],
        ),
        Row(
          children: [
            Text('실행한 날짜: ', style: TextStyles.partName),
            Text(
              '${widget.backtest["executedAt"]}',
              style: TextStyles.valueText,
            ),
            SizedBox(width: 10),
            Text('매칭 횟수: ', style: TextStyles.partName),
            Text(
              '${widget.backtest["matchedCount"]}',
              style: TextStyles.valueText,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey.shade200,
              backgroundImage:
                  (stockImage != null && stockImage.isNotEmpty)
                      ? NetworkImage(stockImage)
                      : null,
              child:
                  (stockImage == null || stockImage.isEmpty)
                      ? const Icon(
                        Icons.image_not_supported,
                        color: Colors.grey,
                        size: 18,
                      )
                      : null,
            ),
            const SizedBox(width: 12),
            Text(
              stockName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            AppButton(
              onPressed: widget.onChangeStock,
              minHeight: 39,
              side: BorderSide(width: 1),
              label: '종목 바꾸기',
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: BacktestResultChart(
            summary: widget.backtest,
            onDetailLoaded: _handleDetailLoaded,
          ),
        ),
        Row(
          children: [
            Text('시작 날짜: ', style: TextStyles.partName),
            Text(
              '${widget.backtest["startDate"]}',
              style: TextStyles.valueText,
            ),
            const SizedBox(width: 13),
            Text('수익률: ', style: TextStyles.partName),
            Text(
              '${_formatPercent(_result["averageReturn"])}',
              style: TextStyles.valueText,
            ),
            const Spacer(),
            TextButton(
              onPressed: widget.onTapDetail,
              style: TextButton.styleFrom(foregroundColor: Color(0xFF9D9D9D)),
              child: const Text('더보기'),
            ),
          ],
        ),
        InfoCardGroup(
          padding: EdgeInsets.zero,
          rows: [
            {
              'label': '승률',
              'value': _formatPercent(_result['winRate']),
            },
            {
              'label': '평균 수익률',
              'value': _formatPercent(_result['averageReturn']),
              'color': const Color(0xFF289BF6),
            },
            {
              'label': '최대 수익률',
              'value': _formatPercent(_result['maxReturn']),
              'subValue': _result['maxReturnDate'],
              'color': const Color(0xFF289BF6),
            },
          ],
        ),
        SizedBox(height: 10),
        if (widget.onRunBacktest != null)
          Center(
            child: AppButton(onPressed: widget.onRunBacktest, label: '다시 돌리기'),
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
    fontSize: 14,
  );
}
