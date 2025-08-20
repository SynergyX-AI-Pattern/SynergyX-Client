// lib/widgets/interest/pattern/pattern_exists_view.dart
import 'package:flutter/material.dart';
import 'package:stockapp/models/pattern_apply.dart';
import 'package:stockapp/widgets/interest/BacktestResultCard.dart';
import 'package:stockapp/widgets/interest/pattern_chart_card.dart';
import 'package:stockapp/widgets/interest/pattern_controls_row.dart';
import 'package:stockapp/widgets/interest/pattern_section_header.dart';

class PatternExistsView extends StatelessWidget {
  final PatternApply data;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final VoidCallback? onRunBacktest;

  const PatternExistsView({
    super.key,
    required this.data,
    this.onDelete,
    this.onEdit,
    this.onRunBacktest,
  });

  @override
  Widget build(BuildContext context) {
    final patt = data.pattern!;

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        const PatternSectionHeader(title: '내 전략 패턴'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: PatternChartCard(points: patt.points), // 차트 위젯 분리
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: PatternControlsRow(
            periodText: '기간: ${patt.periodValue} ${patt.periodUnit}',
            toleranceText: '허용오차: ${patt.tolerance}',
            onDelete: onDelete,
            onEdit: onEdit,
          ),
        ),
        const SizedBox(height: 20),

        const PatternSectionHeader(title: '최근 백테스팅 결과'),
        if (data.hasBacktest)
          BacktestResultCard(result: data.backtest!)
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              onPressed: onRunBacktest,
              icon: const Icon(Icons.play_arrow),
              label: const Text('백테스팅 진행하기'),
            ),
          ),
        const SizedBox(height: 24),
      ],
    );
  }
}
