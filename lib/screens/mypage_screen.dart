import 'package:flutter/material.dart';
import 'package:stockapp/screens/chart_backtest_screen.dart';
import 'package:stockapp/screens/login_screen.dart';

class MypageScreen extends StatelessWidget {
  const MypageScreen({super.key});

  // 로그아웃을 처리하는 메서드
  void _logout(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
            // 백테스팅 화면으로 이동하는 버튼
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChartBacktestScreen(
                      patternData: {
                        'id': 'mock_pattern',
                        'patternName': 'Mock 패턴',
                        'tolerance': 0.05,
                        'periodValue': 30,
                        'periodUnit': '일',
                        'timestamp': DateTime.now()
                            .millisecondsSinceEpoch
                            .toString(),
                      },
                    ),
                  ),
                );
              },
              child: const Text('📈 백테스팅 이동'),
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