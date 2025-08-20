// lib/widgets/interest/pattern/pattern_chip.dart
import 'package:flutter/material.dart';

class PatternChip extends StatelessWidget {
  final String text;
  const PatternChip({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12)),
    );
  }
}
