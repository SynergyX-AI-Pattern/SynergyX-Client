import 'package:flutter/material.dart';
import 'package:stockapp/screens/stock_detail_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  void _handleDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DetailScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('메인페이지'),
              ElevatedButton(
                  onPressed: () => _handleDetail(context),
                  child: const Text('종목 상세 페이지')
              ),
            ],
          ),
        )
    );
  }
}