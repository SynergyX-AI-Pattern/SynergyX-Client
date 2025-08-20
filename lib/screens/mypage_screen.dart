import 'package:flutter/material.dart';

import 'package:stockapp/screens/login_screen.dart';
import 'package:stockapp/screens/profile_edit_screen.dart';
import 'package:stockapp/screens/notification_settings_screen.dart';
import 'package:stockapp/screens/faq_screen.dart';

class MypageScreen extends StatelessWidget {
  const MypageScreen({super.key});

  // 로그아웃을 처리하는 메서드
  void _logout(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  // 회원 정보 수정 화면으로 이동하는 메서드
  void _goToProfileEdit(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfileEditScreen()),
    );
  }

  // 알림 설정 화면으로 이동하는 메서드
  void _goToNotificationSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotificationSettingsScreen()),
    );
  }

  // FAQ 화면으로 이동하는 메서드
  void _goToFaq(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FaqScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      : AppBar(
        title: const Text('마이페이지'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '닉네임: 사용자',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            // 회원 정보 수정 화면으로 이동하는 버튼
            ElevatedButton(
              onPressed: () => _goToProfileEdit(context),
              child: const Text('회원 정보 수정'),
            ),
            const SizedBox(height: 12),
            // 알림 설정 화면으로 이동하는 버튼
            ElevatedButton(
              onPressed: () => _goToNotificationSettings(context),
              child: const Text('알림 설정'),
            ),
            const SizedBox(height: 12),
            // FAQ 화면으로 이동하는 버튼
            ElevatedButton(
              onPressed: () => _goToFaq(context),
              child: const Text('FAQ'),
            ),
            const SizedBox(height: 12),
            // 로그인 화면으로 이동하는 로그아웃 버튼
            ElevatedButton(
              onPressed: () => _logout(context),
              child: const Text('로그아웃'),
            ),
          ],
        ),
      ),
    );
  }
}