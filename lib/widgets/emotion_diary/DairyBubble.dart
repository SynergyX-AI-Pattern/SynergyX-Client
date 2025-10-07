import 'package:flutter/material.dart';

class DiaryBubble extends StatelessWidget {
  final String text;
  final VoidCallback? onDelete;

  const DiaryBubble({super.key, required this.text, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end, // 말풍선 우측 정렬
      crossAxisAlignment: CrossAxisAlignment.end, // 아래 기준 정렬
      children: [
        // 삭제 아이콘 (말풍선 왼쪽 아래)
        if (onDelete != null)
          Row(
            children: [
              // 삭제 아이콘
              IconButton(
                icon: const Icon(
                  Icons.delete,
                  size: 17,
                  color: Color(0xFFB3B3B3),
                ),
                onPressed: onDelete,
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity(horizontal: -3, vertical: -3),
                constraints: const BoxConstraints(maxWidth: 8),
                //splashRadius: 2,
                tooltip: '삭제',
              ),
            ],
          ),

        // 말풍선
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 224),
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              text,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
