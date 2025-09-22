// lib/widgets/common/app_date_picker.dart
import 'package:flutter/material.dart';

Future<DateTime?> showThemedDatePicker(
    BuildContext context, {
      required DateTime initialDate,
      DateTime? firstDate,
      DateTime? lastDate,
    }) {
  return showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: firstDate ?? DateTime(2000, 1, 1),
    lastDate:  lastDate  ?? DateTime(2100, 12, 31),
    builder: (ctx, child) {
      final base = Theme.of(ctx);
      return Theme(
        data: base.copyWith(
          colorScheme: const ColorScheme.light(
            primary: Colors.black,   // 선택칩/헤더 포인트
            onPrimary: Colors.white, // 헤더/선택칩 글자
            onSurface: Colors.black, // 본문 텍스트
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(foregroundColor: Colors.black),
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
}
