import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:stockapp/widgets/common/app_button.dart';
import 'package:stockapp/models/pattern_apply_input.dart';

Future<PatternApplyInput?> showPatternApplyDialog(
    BuildContext context, {
      DateTime? initialDate,
      double? initialMinValidReturn,
      bool isUpdate = false,
      bool barrierDismissible = true,
    }) {
  final dateFmt = DateFormat('yyyy-MM-dd');
  DateTime selected = initialDate ?? DateTime.now();
  final controller =
  TextEditingController(text: (initialMinValidReturn ?? 0).toString());

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
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '패턴적용 설정',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),

                  const Text('패턴 적용 일시',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  TextFormField(
                    readOnly: true,
                    controller:
                    TextEditingController(text: dateFmt.format(selected)),
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: ctx,
                            initialDate: selected,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.light(
                                    primary: Colors.black,
                                    onPrimary: Colors.white,
                                    onSurface: Colors.black,
                                  ),
                                  textButtonTheme: TextButtonThemeData(
                                    style: TextButton.styleFrom(
                                        foregroundColor: Colors.black),
                                  ),
                                  datePickerTheme: const DatePickerThemeData(
                                    headerBackgroundColor: Colors.white,
                                    headerForegroundColor: Colors.black,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (picked != null) setState(() => selected = picked);
                        },
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                    ),
                  ),

                  const SizedBox(height: 12),
                  const Text('최소수익률 조건',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: controller,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true, signed: false),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                    decoration: InputDecoration(
                      hintText: '예: 12.5',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                    ),
                  ),

                  const SizedBox(height: 16),
                  Row(
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
                          final minReturn =
                              double.tryParse(controller.text.trim()) ?? 0.0;
                          final atUtc = DateTime(
                            selected.year,
                            selected.month,
                            selected.day,
                          ).toUtc();
                          Navigator.pop(
                            ctx,
                            PatternApplyInput(
                              entryAt: atUtc,
                              minValidReturn: minReturn,
                            ),
                          );
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
