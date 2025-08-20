import 'package:flutter/material.dart';

/// 회원 정보 수정 화면
///
/// 실제 회원 정보 수정 기능은 추후 구현 예정입니다.
class ProfileEditScreen extends StatelessWidget {
  const ProfileEditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('회원 정보 수정'),
      ),
      body: const Center(
        // 사용자에게 개발 중임을 안내하는 텍스트
        child: Text('회원 정보 수정 화면 (준비중)'),
      ),
    );
  }
}