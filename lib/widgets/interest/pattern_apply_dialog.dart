// lib/widgets/interest/pattern_apply_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:stockapp/widgets/common/app_button.dart';

class PatternApplyInput {
  final DateTime entryAt;       // UTC로 보낼 일시
  final double minValidReturn;  // 최소 수익률
  PatternApplyInput({required this.entryAt, required this.minValidReturn});
}

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
                  const Text('패턴적용 설정',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),

                  const Text('패턴 적용 일시', style: TextStyle(fontWeight: FontWeight.w600)),
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
                                  // 선택된 날짜/헤더 색상 등 핵심 포인트
                                  colorScheme: const ColorScheme.light(
                                    primary: Colors.black,   // 선택된 날짜 배경 & 헤더 강조색
                                    onPrimary: Colors.white, // 선택된 날짜 텍스트 & 헤더 텍스트
                                    onSurface: Colors.black, // 기본 텍스트
                                  ),
                                  // 확인/취소 버튼 색
                                  textButtonTheme: TextButtonThemeData(
                                    style: TextButton.styleFrom(foregroundColor: Colors.black),
                                  ),
                                  // 세부 커스터마이즈 (Flutter 3.10+)
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
                  const Text('최소수익률 조건', style: TextStyle(fontWeight: FontWeight.w600)),
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
                        side: BorderSide(color: Colors.black, width: 1),
                      ),
                      const SizedBox(width: 8),
                      AppButton(
                        onPressed: () {
                          final minReturn =
                              double.tryParse(controller.text.trim()) ?? 0.0;
                          // 날짜만 선택 → 자정(로컬)을 UTC로 변환
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
