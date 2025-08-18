import 'package:flutter/material.dart';
import 'package:stockapp/screens/chart_backtest_screen.dart';
import 'package:stockapp/screens/image_search_screen.dart';

class MypageScreen extends StatelessWidget {
  const MypageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mypage Screen')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 기존: 백테스팅 이동
            ElevatedButton(
              onPressed: () {
                Navigator.of(context, rootNavigator: false).push(
                  MaterialPageRoute(
                    builder:
                        (_) => ChartBacktestScreen(
                          patternData: {
                            'id': 'mock_pattern',
                            'patternName': 'Mock 패턴',
                            'tolerance': 0.05,
                            'periodValue': 30,
                            'periodUnit': '일',
                            'timestamp':
                                DateTime.now().millisecondsSinceEpoch
                                    .toString(),
                          },
                        ),
                  ),
                );
              },
              child: const Text('📈 백테스팅 이동'),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.image_search),
              label: const Text('🖼 AI 이미지 종목검색 이동'),
              onPressed: () {
                Navigator.of(context, rootNavigator: false).push(
                  MaterialPageRoute(builder: (_) => const ImageSearchScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
