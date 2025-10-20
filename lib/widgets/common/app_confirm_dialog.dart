import 'package:flutter/material.dart';

class AppConfirmDialog extends StatelessWidget {
  final String title;
  final String cancelText;
  final String confirmText;
  final String? content;

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

      // 내부 여백 조정
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      actionsPadding: const EdgeInsets.fromLTRB(8, 0, 8, 8),

      title: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),

      content:
          content == null
              ? null
              : Text(
                content!,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                  height: 1.4, // 줄간격
                ),
              ),

      actionsAlignment: MainAxisAlignment.end, // 버튼 오른쪽 정렬
      actionsOverflowButtonSpacing: 0,

      // 버튼 영역
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          onPressed: () => Navigator.pop(context, false),
          child: Text(
            cancelText,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ),
        TextButton(
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          onPressed: () => Navigator.pop(context, true),
          child: Text(
            confirmText,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
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
  bool barrierDismissible = true,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder:
        (_) => AppConfirmDialog(
          title: title,
          content: content,
          cancelText: cancelText,
          confirmText: confirmText,
        ),
  );
}
