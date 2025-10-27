import 'package:flutter/material.dart';

class InfoDialog extends StatelessWidget {
  final String title;
  final String description;

  const InfoDialog({super.key, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      titlePadding: const EdgeInsets.fromLTRB(20, 10, 10, 0),
      contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      title: Row(
        children: [
          Text(title, style: TextStyles.title),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      content: Text(
        description,
        style: const TextStyle(fontSize: 14, height: 1.2),
      ),
    );
  }
}

/// styles
class TextStyles {
  static const TextStyle title = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 19,
  );
}
