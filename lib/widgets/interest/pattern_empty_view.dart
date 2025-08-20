// lib/widgets/interest/pattern/pattern_empty_view.dart
import 'package:flutter/material.dart';
import 'package:stockapp/widgets/interest/pattern_section_header.dart';

class PatternEmptyView extends StatelessWidget {
  const PatternEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const PatternSectionHeader(title: '내 전략 패턴'),
        const SizedBox(height: 40),
        Center(
          child: Column(
            children: [
              const Text('설정된 차트 패턴이 없습니다.'),
              const SizedBox(height: 10),
              FilledButton(
                onPressed: () {/* 패턴 추가 화면 이동 */},
                child: const Text('패턴 추가하기'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
