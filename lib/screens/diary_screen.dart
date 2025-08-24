import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stockapp/data/emotion_diary_api.dart';
import 'package:stockapp/widgets/emotion_diary/DairyBubble.dart';
import 'package:stockapp/widgets/emotion_diary/EmotionAnalysisCard.dart';
import 'package:stockapp/widgets/emotion_diary/EmotionHeader.dart';
import 'package:stockapp/widgets/emotion_diary/EmotionInputBar.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  final EmotionDiaryApi _api = EmotionDiaryApi();

  List<Map<String, dynamic>> _diaryList = [];

  @override
  void initState() {
    super.initState();
    _loadDiaries();
  }

  Future<void> _loadDiaries() async {
    final result = await _api.fetchDiaries();
    setState(() {
      _diaryList = result.toList(); // 최신순
    });
  }

  Future<void> _submitDiary(Map<String, dynamic> result) async {
    await _loadDiaries(); // 새 일기 등록 후 목록 갱신
  }

  //날짜 포멧
  String formatDate(dynamic createdAt) {
    try {
      final String isoString = createdAt.toString();
      final trimmed = isoString.split('.').first;
      final date = DateTime.parse(trimmed);
      return DateFormat('yyyy년 M월 d일', 'ko').format(date);
    } catch (e) {
      print('날짜 포맷팅 실패: $e');
      return '날짜 없음';
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const EmotionHeader(),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _diaryList.length,
                itemBuilder: (context, index) {
                  final diary = _diaryList[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      Center(
                        child: Text(
                          formatDate(diary['createdAt']),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                      const SizedBox(height: 6),
                      DiaryBubble(text: diary['content'] ?? ''),
                      const SizedBox(height: 8),
                      EmotionAnalysisCard(
                        emotions: List<String>.from(diary['emotion'] ?? []),
                        summary: diary['summary'] ?? '',
                        feedback: diary['feedback'] ?? '',
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: EmotionInputBar(onSubmit: _submitDiary),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

