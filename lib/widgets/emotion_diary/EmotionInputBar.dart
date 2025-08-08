import 'package:flutter/material.dart';

class EmotionInputBar extends StatefulWidget {
  const EmotionInputBar({super.key});

  @override
  State<EmotionInputBar> createState() => _EmotionInputBarState();
}

class _EmotionInputBarState extends State<EmotionInputBar> {
  final TextEditingController _controller = TextEditingController();

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      // 여기에 전송 로직 추가 (예: print, 서버 전송 등)
      print("✉️ 감정 일기 전송: $text");
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: _controller,
        onSubmitted: (_) => _handleSend(),
        decoration: InputDecoration(
          hintText: '오늘 투자하며 느낀 감정을 자유롭게 적어보세요.',
          filled: true,
          fillColor: Color(0xFFF2F2F2),
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          suffixIcon: IconButton(
            icon: const Icon(Icons.send),
            onPressed: _handleSend,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
