import 'package:flutter/material.dart';
import 'package:stockapp/screens/chart_backtest_screen.dart';

class MypageScreen extends StatelessWidget {
  const MypageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mypage Screen'),
      ),
      body: Center(
        child: ElevatedButton(
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
                    'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
                  },
                ),
              )
            );
          },
          child: const Text('📈 백테스팅 이동'),
        ),
      ),
    );
  }
}
