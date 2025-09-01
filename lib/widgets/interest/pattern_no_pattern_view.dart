import 'package:flutter/material.dart';

class PatternNoPatternView extends StatelessWidget {
  final VoidCallback? onCreate; // 선택: "패턴 설정" 같은 액션이 필요하면 전달

  const PatternNoPatternView({super.key, this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('등록된 패턴이 없습니다.'),
        const SizedBox(height: 10),
        if (onCreate != null)
          FilledButton(onPressed: onCreate, child: const Text('패턴 설정하러 가기')),
      ]),
    );
  }
}
