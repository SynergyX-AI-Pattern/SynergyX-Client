// lib/widgets/interest/pattern/pattern_controls_row.dart
import 'package:flutter/material.dart';
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
        OutlinedButton(onPressed: onDelete, child: const Text('삭제')),
        const SizedBox(width: 8),
        FilledButton.tonal(onPressed: onEdit, child: const Text('수정')),
      ],
    );
  }
}
