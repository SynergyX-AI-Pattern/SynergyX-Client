import 'package:flutter/material.dart';
import 'package:stockapp/models/pattern_apply.dart';
import 'package:stockapp/widgets/common/app_button.dart';
import 'package:stockapp/widgets/common/pattern_line_chart.dart';
import 'package:stockapp/widgets/interest/BacktestResultCard.dart';
import 'package:stockapp/widgets/interest/pattern_alert_button.dart';
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
                child: Text('내 전략 패턴', style: TextStyles.sectionHeader),
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
          child: Container(
            decoration: BoxDecoration(
              color: Color(0xFFF4F4F4),
              borderRadius: BorderRadius.circular(8),
            ),
              padding: const EdgeInsets.all(12),
              child: Container(
                color: Colors.white,
                  child: PatternLineChart(points: patt.points)
              )
          ),
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
        SizedBox(height: 8),
        const SizedBox(height: 13, child: DecoratedBox(
          decoration: BoxDecoration(
            color: Color(0xFFEFEFEF),
          ),
        ),),
        SizedBox(height: 10),

        // 백테스팅
        // const PatternSectionHeader(title: '최근 백테스팅 결과'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Text('최근 백테스팅 결과', style: TextStyles.sectionHeader),
        ),
        if (data.hasBacktest)
          Column(
            children: [
              BacktestResultCard(result: data.backtest!),
              SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: AppButton(label: '다시 돌리기', onPressed: onRunBacktest),
                ),
              )
            ]
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AppButton(
                label: '백테스팅 진행하기',
                onPressed: onRunBacktest),
          ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class TextStyles {
  static const TextStyle sectionHeader = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 19,
  );

}
