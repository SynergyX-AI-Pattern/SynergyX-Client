import 'package:flutter/material.dart';

class DiaryBubble extends StatelessWidget {
  final String text;

  const DiaryBubble({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 224), // ✅ 최대 너비 제한
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
