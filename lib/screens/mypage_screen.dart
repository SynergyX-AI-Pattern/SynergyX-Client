import 'package:flutter/material.dart';

import 'package:stockapp/screens/login_screen.dart';
import 'package:stockapp/screens/profile_edit_screen.dart';
import 'package:stockapp/screens/notification_settings_screen.dart';
import 'package:stockapp/screens/faq_screen.dart';
import 'package:stockapp/screens/interest/interest_screen.dart';


class MypageScreen extends StatelessWidget {
  const MypageScreen({
    super.key,
    this.userName = '김덕성',
    this.email = '19200419-@duksung.ac.kr',
  });

  final String userName;
  final String email;

  void _logout(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void _goToInterestEdit(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const InterestScreen()),
    );
  }

  void _goToProfileEdit(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfileEditScreen()),
    );
  }

  void _goToNotificationSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotificationSettingsScreen()),
    );
  }

  void _goToFaq(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FaqScreen()),
    );
  }

  void _withdraw(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('탈퇴하기'),
        content: const Text('정말로 탈퇴하시겠어요? 이 작업은 되돌릴 수 없습니다.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('탈퇴')),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      // 탈퇴 등록
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
            (_) => false,
      );
    }
  }

  Widget _sectionSpacer() => Container(
    height: 12,
    color: const Color(0xFFF1F2F4), // 디자인의 연한 회색 구분 바
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.3,
        centerTitle: true,
        title: const Text('MyPage', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
      body: SafeArea(
        child: ListView(
          children: [
            // 상단 프로필 영역
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: const Color(0xFF2E2E2E),
                    child: Text(
                      userName.isNotEmpty ? userName.characters.first : ' ',
                      style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(userName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(
                          email,
                          style: TextStyle(fontSize: 13, color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            _sectionSpacer(),

            // 메뉴 섹션 1
            _MenuTile(
              icon: Icons.person_outline,
              title: '프로필수정',
              onTap: () => _goToProfileEdit(context),
            ),
            _divider(),
            _MenuTile(
              icon: Icons.favorite_border,
              title: '관심 종목 편집',
              onTap: () => _goToInterestEdit(context),
            ),
            _divider(),
            _MenuTile(
              icon: Icons.notifications_none,
              title: '알림 설정',
              onTap: () => _goToNotificationSettings(context),
            ),
            _divider(),
            _MenuTile(
              icon: Icons.help_outline,
              title: 'FAQ',
              onTap: () => _goToFaq(context),
            ),

            _sectionSpacer(),

            // 메뉴 섹션 2
            _MenuTile(
              icon: Icons.logout,
              title: '로그아웃',
              onTap: () => _logout(context),
            ),

            _sectionSpacer(),

            // 탈퇴하기 (빨간색)
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              leading: const Icon(Icons.exit_to_app, color: Colors.redAccent),
              title: const Text(
                '탈퇴하기',
                style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600),
              ),
              onTap: () => _withdraw(context),
            ),

            // 하단 여백
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _divider() => const Divider(height: 1, thickness: 0.6, indent: 16, endIndent: 16);
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.title,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      leading: Icon(icon, color: const Color(0xFF4B5563)),
      title: Text(title, style: const TextStyle(fontSize: 15)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
