// lib/widgets/interest/backtest_config_dialog.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stockapp/widgets/common/app_button.dart';
import 'package:stockapp/widgets/common/dialog/app_date_field.dart';

class BacktestConfig {
  final DateTime startDate;
  final DateTime endDate;
  BacktestConfig({required this.startDate, required this.endDate});
}

Future<BacktestConfig?> showBacktestConfigDialog(
    BuildContext context, {
      DateTime? initialStart,
      DateTime? initialEnd,
    }) {
  DateTime start = initialStart ?? DateTime.now().subtract(const Duration(days: 30));
  DateTime end   = initialEnd   ?? DateTime.now();

  bool isValidRange() {
    final s = DateTime(start.year, start.month, start.day);
    final e = DateTime(end.year, end.month, end.day);
    return !e.isBefore(s);
  }

  return showDialog<BacktestConfig>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          backgroundColor: Colors.white,
          title: const Text('백테스팅 설정', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20)),
          content: SizedBox(
            width: 360,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppDateField(
                  label: '백테스팅 시작 날짜',
                  value: start,
                  onChanged: (d) => setState(() => start = d),
                  format: DateFormat('yyyy-MM-dd'),
                ),
                const SizedBox(height: 12),
                AppDateField(
                  label: '백테스팅 종료 날짜',
                  value: end,
                  onChanged: (d) => setState(() => end = d),
                  format: DateFormat('yyyy-MM-dd'),
                ),
                if (!isValidRange())
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text('종료일은 시작일 이후여야 해요', style: TextStyle(color: Colors.red)),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            AppButton(label: '취소', onPressed: () => Navigator.pop(ctx),
              textStyle: TextStyle(fontSize: 13),
              fgColor: Colors.black,
              bgColor:  Color(0xFFF5F5F5),
              side: BorderSide(color: Colors.black, width: 1),),
            AppButton(label: '백테스팅 진행',
                textStyle: TextStyle(fontSize: 13),
              onPressed: isValidRange()
                ? () => Navigator.pop(ctx, BacktestConfig(startDate: start, endDate: end))
                : null,),
          ],
        ),
      );
    },
  );
}
