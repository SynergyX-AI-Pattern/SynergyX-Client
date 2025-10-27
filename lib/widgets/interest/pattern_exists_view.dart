import 'package:flutter/material.dart';
import 'package:stockapp/models/pattern_apply.dart';
import 'package:stockapp/widgets/common/app_button.dart';
import 'package:stockapp/widgets/common/dialog/info_dialog.dart';
import 'package:stockapp/widgets/common/pattern_line_chart.dart';
import 'package:stockapp/widgets/interest/BacktestResultCard.dart';
import 'package:stockapp/widgets/interest/pattern_alert_button.dart';
import 'package:stockapp/widgets/interest/pattern_controls_row.dart';

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
                  initialEnabled: data.isAlertEnabled ?? false,
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
              child: PatternLineChart(points: patt.points),
            ),
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
        const SizedBox(height: 8),
        const SizedBox(
          height: 13,
          width: double.infinity,
          child: DecoratedBox(
            decoration: BoxDecoration(color: Color(0xFFEFEFEF)),
          ),
        ),
        const SizedBox(height: 10),

        // 백테스팅
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            children: [
              Text('최근 백테스팅 결과', style: TextStyles.sectionHeader),
              SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder:
                        (_) => const InfoDialog(
                          title: '백테스팅이란?',
                          description:
                              '내 전략 패턴이 실제 투자에 도움이 되는지를 \n과거 주가 데이터를 기반으로 검증하는 기능입니다.\n\n'
                              '패턴이 일어난 구간의 수익률, 승률, 최대 수익일 등을 통해 패턴의 신뢰도를 확인할 수 있습니다.',
                        ),
                  );
                },
                child: const Icon(
                  Icons.info_outline,
                  size: 20,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        if (data.hasBacktest)
          Column(
            children: [
              BacktestResultCard(result: data.backtest!),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: AppButton(label: '다시 돌리기', onPressed: onRunBacktest),
                ),
              ),
            ],
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Center(
              child: AppButton(label: '백테스팅 진행하기', onPressed: onRunBacktest),
            ),
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
