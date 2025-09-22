// lib/widgets/interest/pattern_apply_dialog.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stockapp/widgets/common/app_button.dart';
import 'package:stockapp/models/pattern_apply_input.dart';
import 'package:stockapp/widgets/common/dialog/app_date_field.dart';
import 'package:stockapp/widgets/common/dialog/app_number_field.dart';

Future<PatternApplyInput?> showPatternApplyDialog(
    BuildContext context, {
      DateTime? initialDate,
      double? initialMinValidReturn,
      bool isUpdate = false,
      bool barrierDismissible = true,
    }) {
  DateTime selected = initialDate ?? DateTime.now();
  final minCtrl = TextEditingController(text: (initialMinValidReturn ?? 0).toString());

  return showDialog<PatternApplyInput>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (ctx) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: StatefulBuilder(
            builder: (ctx, setState) => SingleChildScrollView(
              padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('패턴적용 설정', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),

                  AppDateField(
                    label: '패턴 적용 일시',
                    value: selected,
                    onChanged: (d) => setState(() => selected = d),
                    format: DateFormat('yyyy-MM-dd'),
                  ),
                  const SizedBox(height: 12),

                  AppNumberField(
                    label: '최소수익률 조건',
                    controller: minCtrl,
                    hintText: '예: 12.5',
                  ),

                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      AppButton(
                        onPressed: () => Navigator.pop(ctx),
                        label: '취소',
                        bgColor: Colors.white,
                        fgColor: Colors.black,
                        side: const BorderSide(color: Colors.black, width: 1),
                      ),
                      const SizedBox(width: 8),
                      AppButton(
                        onPressed: () {
                          final minReturn = double.tryParse(minCtrl.text.trim()) ?? 0.0;
                          final atUtc = DateTime(selected.year, selected.month, selected.day).toUtc();
                          Navigator.pop(ctx, PatternApplyInput(entryAt: atUtc, minValidReturn: minReturn));
                        },
                        label: (isUpdate ? '패턴 수정' : '패턴 추가'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
