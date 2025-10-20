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
  bool _isSending = false;

  Future<void> _handleSend() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSending = true);

    try {
      final result = await _api.postDiary(text); // 감정 분석 결과 받기
      widget.onSubmit(result); // 부모에게 결과 전달

      _controller.clear();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('전송 실패: $e')));
    } finally {
      setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 로딩 텍스트
          if (_isSending)
            const Padding(
              padding: EdgeInsets.only(top: 2, bottom: 8),
              child: Text(
                '감정 분석 중 입니다...',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          // 입력창
          TextField(
            controller: _controller,
            onSubmitted: (_) => _handleSend(),
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            decoration: InputDecoration(
              hintText: '오늘 투자하며 느낀 감정을 자유롭게 적어보세요.',
              hintStyle: const TextStyle(color: Color(0xFF8D8D8D)),
              filled: true,
              fillColor: const Color(0xFFF2F2F2),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 20,
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.send),
                color: Colors.black,
                onPressed: _isSending ? null : _handleSend, // 전송 중이면 비활성화
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
