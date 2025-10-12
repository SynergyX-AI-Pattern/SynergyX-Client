import 'package:flutter/material.dart';
import 'package:stockapp/widgets/interest/pattern_section_header.dart';

class PatternEmptyView extends StatelessWidget {
  final VoidCallback? onAdd;

  const PatternEmptyView({super.key, this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PatternSectionHeader(title: '내 전략 패턴'),
        const SizedBox(height: 40),
        Center(
          child: Column(
            children: [
              const Text('설정된 차트 패턴이 없습니다.'),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: onAdd,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.black,
                  textStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
                  padding: EdgeInsets.all(12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('패턴 추가하기'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
