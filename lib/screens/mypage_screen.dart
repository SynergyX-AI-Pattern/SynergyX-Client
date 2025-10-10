import 'package:flutter/material.dart';
import 'package:stockapp/screens/backtest/backtest_ranking_screen.dart';
import 'package:stockapp/screens/interest/interest_screen.dart';
import 'package:stockapp/screens/login_screen.dart';
import 'package:stockapp/screens/notification_settings_screen.dart';
import 'package:stockapp/services/auth_service.dart';
import 'package:stockapp/services/auth_state.dart';
import 'package:stockapp/services/user_service.dart';

// 마이페이지 화면: 사용자 정보 표시 및 다양한 설정 항목 제공
class MypageScreen extends StatefulWidget {
  const MypageScreen({super.key});

  @override
  State<MypageScreen> createState() => _MypageScreenState();
}

class _MypageScreenState extends State<MypageScreen> {
  // 화면에 표시할 사용자명과 이메일을 상태로 관리
  String _userName = AuthState.username ?? '';
  final String _email = AuthState.email ?? '';

  /// 프로필(이름) 수정 다이얼로그를 띄우고 서버에 저장
  Future<void> _editProfile(BuildContext context) async {
    final controller = TextEditingController(text: _userName);
    final newName = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('이름 수정'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: '새 이름'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('저장'),
          ),
        ],
      ),
    );

    if (newName == null || newName.isEmpty) return;

    final res = await UserService().updateProfile(newName);
    if (!mounted) return;
    if (res.isSuccess) {
      // 상태와 AuthState에 새로운 이름을 반영
      setState(() => _userName = newName);
      AuthState.username = newName;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('프로필이 수정되었습니다.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res.message ?? '프로필 수정에 실패했습니다')),
      );
    }
  }

  /// 로그아웃 처리
  Future<void> _logout(BuildContext context) async {
    // 토큰이 없으면 바로 로그인 화면으로 이동
    if (AuthState.accessToken == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }
    final res = await AuthService().logout();
    if (!context.mounted) return;
    if (res.isSuccess) {
      await AuthState.clear();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
            (_) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res.message ?? '로그아웃에 실패했습니다')),
      );
    }
  }

  void _goToInterestEdit(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const InterestScreen()),
    );
  }

  void _goToNotificationSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotificationSettingsScreen()),
    );
  }

  void _goToBacktestRankingScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const BacktestRankingScreen()),
    );
  }

  Future<void> _withdraw(BuildContext context) async {
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
    if (ok != true) return;
    if (AuthState.accessToken == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }
    final res = await AuthService().withdraw();
    if (!context.mounted) return;
    if (res.isSuccess) {
      await AuthState.clear();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
            (_) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res.message ?? '탈퇴에 실패했습니다')),
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
                      _userName.isNotEmpty ? _userName.characters.first : ' ',
                      style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_userName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(
                          _email,
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
              onTap: () => _editProfile(context),
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
              icon: Icons.emoji_events_outlined,
              title: '백테스트 랭킹',
              onTap: () => _goToBacktestRankingScreen(context),
            ),
            _divider(),
            _MenuTile(
              icon: Icons.help_outline,
              title: 'FAQ',
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

            _sectionSpacer(),

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
