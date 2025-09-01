// lib/widgets/interest/pattern/pattern_controls_row.dart
import 'package:flutter/material.dart';
import 'package:stockapp/widgets/common/app_button.dart';
import 'package:stockapp/widgets/interest/pattern_chip.dart';

class PatternControlsRow extends StatelessWidget {
  final String periodText;
  final String toleranceText;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const PatternControlsRow({
    super.key,
    required this.periodText,
    required this.toleranceText,
    this.onDelete,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        PatternChip(text: periodText),
        const SizedBox(width: 8),
        PatternChip(text: toleranceText),
        const Spacer(),
        AppButton(
            label: '삭제',
            textStyle: TextStyle(fontSize: 13),
            fgColor: Colors.black,
            bgColor:  Color(0xFFF5F5F5),
            side: BorderSide(color: Colors.black, width: 1),
            onPressed: onDelete
        ),
        const SizedBox(width: 8),
        AppButton(
            label: '수정',
            textStyle: TextStyle(fontSize: 13),
            onPressed: onEdit),
      ],
    );
  }
}
