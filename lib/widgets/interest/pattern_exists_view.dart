// lib/widgets/interest/pattern/pattern_exists_view.dart
import 'package:flutter/material.dart';
import 'package:stockapp/models/pattern_apply.dart';
import 'package:stockapp/widgets/interest/BacktestResultCard.dart';
import 'package:stockapp/widgets/interest/pattern_alert_button.dart';
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
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        // 헤더 + 알림 버튼 행
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Expanded(
                child: PatternSectionHeader(title: '내 전략 패턴'),
              ),
              if (data.patternApplyId != null)
                PatternAlertButton(
                  patternApplyId: data.patternApplyId!,
                  initialEnabled: data.isAlertEnabled ?? false, // 모델에 없으면 false
                )
              else
                IconButton(
                  onPressed: null,
                  icon: const Icon(Icons.notifications_none),
                  tooltip: '패턴 적용 후 사용 가능',
                ),
            ],
          ),
        ),

        // 차트
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: PatternChartCard(points: patt.points),
        ),
        const SizedBox(height: 12),

        // 컨트롤
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

        // 백테스팅
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
