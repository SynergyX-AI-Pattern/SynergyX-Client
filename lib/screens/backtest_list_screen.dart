import 'package:flutter/material.dart';
import 'package:stockapp/screens/backtest_result_screen.dart';
import 'package:stockapp/data/backtest_api.dart';


class BacktestListScreen extends StatefulWidget {
  final int? patternId; // 특정 패턴의 결과만 보고 싶을 때 사용

  /// [patternId]가 주어지면 해당 패턴의 백테스트만 조회한다.
  const BacktestListScreen({super.key, this.patternId});

  @override
  State<BacktestListScreen> createState() => _BacktestListScreenState();
}

class _BacktestListScreenState extends State<BacktestListScreen> {
  late Future<List<Map<String, dynamic>>> _future; // API 호출 결과

  @override
  void initState() {
    super.initState();
    // 패턴 ID가 있으면 해당 패턴만 필터링, 없으면 전체 목록을 조회
    _future = BacktestService.fetchBacktestList(patternId: widget.patternId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('백테스트 목록')),
      body: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('에러 발생: ${snapshot.error}'));
          }

          final list = snapshot.data!;
          if (list.isEmpty) {
            return const Center(child: Text('백테스트 결과가 없습니다.'));
          }

          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, index) {
              final item = list[index];
              return ListTile(
                title: Text('${item['stockName']}'),
                subtitle: Text('실행일: ${item['executedAt']}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  final detail = await BacktestService.fetchBacktestResult(item['backtestId']);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BacktestResultScreen(result: detail),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
