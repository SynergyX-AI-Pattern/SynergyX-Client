import 'package:flutter/material.dart';
import 'package:stockapp/data/emotion_diary_api.dart';

class EmotionInputBar extends StatefulWidget {
  final Function(Map<String, dynamic>) onSubmit;

  const EmotionInputBar({super.key, required this.onSubmit});

  @override
  State<EmotionInputBar> createState() => _EmotionInputBarState();
}

class _EmotionInputBarState extends State<EmotionInputBar> {
  final TextEditingController _controller = TextEditingController();
  final EmotionDiaryApi _api = EmotionDiaryApi();

  Future<void> _handleSend() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    try {
      final result = await _api.postDiary(text); // 감정 분석 결과 받기

      widget.onSubmit(result); // 부모에게 결과 전달

      print('✅ 감정 일기 전송 완료'); // 콘솔 출력
      _controller.clear();
    } catch (e) {
      print('❌ 감정 일기 전송 실패: $e'); // 실패 로그만 출력
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
          fillColor: const Color(0xFFF2F2F2),
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
