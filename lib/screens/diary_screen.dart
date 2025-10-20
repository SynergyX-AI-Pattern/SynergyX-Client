import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stockapp/data/emotion_diary_api.dart';
import 'package:stockapp/widgets/common/app_confirm_dialog.dart';
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
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> _diaryList = [];

  @override
  void initState() {
    super.initState();
    _loadDiaries();
  }

  // 데이터 로드 후 맨 아래로 이동
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _loadDiaries() async {
    final result = await _api.fetchDiaries();
    setState(() {
      _diaryList = result.toList();
    });
    _scrollToBottom();
  }

  Future<void> _submitDiary(Map<String, dynamic> result) async {
    await _loadDiaries();
  }

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

  Map<String, List<Map<String, dynamic>>> groupDiariesByDate(
    List<Map<String, dynamic>> diaries,
  ) {
    final Map<String, List<Map<String, dynamic>>> grouped = {};

    for (final diary in diaries) {
      final createdAt = diary['createdAt'];
      if (createdAt == null) continue;

      final dateKey = createdAt.toString().substring(0, 10);
      grouped.putIfAbsent(dateKey, () => []);
      grouped[dateKey]!.add(diary);
    }

    return grouped;
  }

  void _confirmDelete(int diaryId) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder:
          (context) => AppConfirmDialog(
            title: '일기 삭제',
            content: '정말 이 감정일기를 삭제하시겠습니까?',
            cancelText: '취소',
            confirmText: '삭제',
          ),
    );

    if (shouldDelete == true) {
      await _api.deleteDiary(diaryId);
      _loadDiaries(); // 목록 새로고침
    }
  }

  List<Widget> _buildGroupedDiaryWidgets() {
    final grouped = groupDiariesByDate(_diaryList);
    final sortedDateKeys =
        grouped.keys.toList()..sort((a, b) => a.compareTo(b));

    final List<Widget> widgets = [];

    for (final dateKey in sortedDateKeys) {
      final dateFormatted = formatDate(dateKey);

      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Center(
            child: Text(
              dateFormatted,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ),
      );

      for (final diary in grouped[dateKey]!) {
        widgets.addAll([
          const SizedBox(height: 6),
          DiaryBubble(
            text: diary['content'] ?? '',
            onDelete: () => _confirmDelete(diary['diaryId']),
          ),
          const SizedBox(height: 8),
          EmotionAnalysisCard(
            emotions: List<String>.from(diary['emotion'] ?? []),
            summary: diary['summary'] ?? '',
            feedback: diary['feedback'] ?? '',
          ),
          const SizedBox(height: 16),
        ]);
      }
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const EmotionHeader(),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                controller: _scrollController, //페이지 진입 시 맨 아래로 이동
                padding: const EdgeInsets.symmetric(horizontal: 15),
                children: _buildGroupedDiaryWidgets(),
              ),
            ),
            SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: EmotionInputBar(onSubmit: _submitDiary),
            ),
          ],
        ),
      ),
    );
  }
}
