import 'package:flutter/material.dart';

class PatternNoPatternView extends StatelessWidget {
  final VoidCallback? onCreate; // 선택: "패턴 설정" 같은 액션이 필요하면 전달

  const PatternNoPatternView({super.key, this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '설정한 전략 패턴이 없습니다.',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 10),
          Text(
            '패턴 페이지에서 패턴을 추가해 주세요.',
            style: TextStyle(
              color: Color(0xFF807F7F),
              fontWeight: FontWeight.w500,
            ),
          ),
          // if (onCreate != null)
          //   FilledButton(onPressed: onCreate, child: const Text('패턴 설정하러 가기')),
        ],
      ),
    );
  }
}
