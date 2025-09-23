import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

// ─ 로딩 다이얼로그
void showLoadingDialog(BuildContext context, CancelToken? cancelToken) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogCtx) {
      return WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Padding(
            padding: const EdgeInsets.only(top: 24),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: Color(0xFF1A237E),
                  ),
                ),
                SizedBox(width: 16),
                Text(
                  '이미지 업로드 중...',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          actionsAlignment: MainAxisAlignment.end,
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2C2C2C),
                foregroundColor: const Color(0xFFF5F5F5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 20,
                ),
                minimumSize: const Size(80, 36), // 버튼 최소 크기 지정
              ),
              onPressed: () {
                cancelToken?.cancel('사용자 취소');
                Navigator.of(dialogCtx).pop(); // 다이얼로그 닫음
              },
              child: const Text(
                '취소',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      );
    },
  );
}
