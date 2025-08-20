import 'package:flutter/material.dart';

/// 알림 설정 화면
///
/// 사용자에게 알림 관련 설정 옵션을 제공하는 화면입니다.
/// 실제 기능은 이후에 추가될 예정입니다.
class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('알림 설정'),
      ),
      body: const Center(
        // 현재는 안내 문구만 표시
        child: Text('알림 설정 화면 (준비중)'),
      ),
    );
  }
}