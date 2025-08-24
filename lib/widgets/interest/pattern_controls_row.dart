// lib/widgets/interest/pattern/pattern_controls_row.dart
import 'package:flutter/material.dart';
import 'package:stockapp/widgets/interest/pattern_chip.dart';

class PatternControlsRow extends StatelessWidget {
  final String periodText;
  final String toleranceText;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const PatternControlsRow({
    super.key,
    required this.periodText,
    required this.toleranceText,
    this.onDelete,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        PatternChip(text: periodText),
        const SizedBox(width: 8),
        PatternChip(text: toleranceText),
        const Spacer(),
        ElevatedButton(
          onPressed: onDelete,
          style: ElevatedButton.styleFrom(
            // 메인 컬러
            // primary: Colors.red, // Deprecated
            // 텍스트색상, ripple컬러
            foregroundColor: Colors.black,
            // 버튼 배경 색
            backgroundColor: Color(0xFFF5F5F5),
            textStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
            // 글자 주변에 적용
            padding: EdgeInsets.all(12),
            // 테두리 설정
            side: BorderSide(color: Colors.black, width: 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text('삭제'),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: onEdit,
          style: ElevatedButton.styleFrom(
            // 메인 컬러
            // primary: Colors.red, // Deprecated
            // 텍스트색상, ripple컬러
            foregroundColor: Colors.white,
            // 버튼 배경 색
            backgroundColor: Colors.black,
            textStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
            // 글자 주변에 적용
            padding: EdgeInsets.all(12),
            // 테두리 설정
            side: BorderSide(color: Colors.black, width: 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text('수정'),
        ),
      ],
    );
  }
}
