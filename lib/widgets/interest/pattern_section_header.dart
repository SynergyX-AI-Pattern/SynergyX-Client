// lib/widgets/interest/pattern/pattern_section_header.dart
import 'package:flutter/material.dart';

class PatternSectionHeader extends StatelessWidget {
  final String title;
  const PatternSectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
    );
  }
}
