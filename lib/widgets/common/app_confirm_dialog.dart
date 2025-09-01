import 'package:flutter/material.dart';

class AppConfirmDialog extends StatelessWidget {
  final String title;
  final String cancelText;
  final String confirmText;
  final String? content; // 본문이 필요하면 사용 (선택)

  const AppConfirmDialog({
    super.key,
    required this.title,
    this.cancelText = '취소',
    this.confirmText = '적용',
    this.content,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      ),
      content: content == null
          ? null
          : Text(
        content!,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text(
            '취소',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.black),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text(
            '적용',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.black),
          ),
        ),
      ],
    );
  }
}

Future<bool?> showAppConfirmDialog(
    BuildContext context, {
      required String title,
      String? content,
      String cancelText = '취소',
      String confirmText = '적용',
      bool barrierDismissible = true, //바깥 터치로 닫히도록
    }) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (_) => AppConfirmDialog(
      title: title,
      content: content,
      cancelText: cancelText,
      confirmText: confirmText,
    ),
  );
}
