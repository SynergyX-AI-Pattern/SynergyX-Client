import 'package:flutter/material.dart';

class ToggleInfo extends StatelessWidget {
  final bool showInfo;  // 정보를 표시할지 여부
  final VoidCallback toggleInfo;  // 상태 변경을 위한 콜백

  const ToggleInfo({
    super.key,
    required this.showInfo,
    required this.toggleInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(
          icon: const Icon(Icons.info_outline),  // 정보 버튼 아이콘
          onPressed: toggleInfo,  // 버튼 클릭 시 토글 상태 변경
        ),
        if (showInfo)  // showInfo가 true일 때만 정보 표시
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.grey[200],
            child: const Text(
              '도움말: 재무정보란?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
      ],
    );
  }
}
