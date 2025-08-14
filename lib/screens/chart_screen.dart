import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stockapp/data/pattern_api.dart';
import 'package:stockapp/models/pattern.dart';
import 'dart:convert';

import 'package:stockapp/screens/chart_detail_screen.dart';
import 'package:stockapp/screens/chart_new_screen.dart';

class ChartScreen extends StatefulWidget {
  const ChartScreen({super.key});

  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  List<Pattern> patterns = [];
  List<File> previewImages = [];
  bool isLoading = true;

  Future<Directory> _docsDir() => getApplicationDocumentsDirectory(); // (편의 헬퍼, 있으면 유지)

  @override
  void initState() {
    super.initState();
    _fetchPatterns();
  }

  Future<void> _fetchPatterns() async {
    try {
      final result = await PatternApi.getPatterns();

      final dir = await _docsDir();
      final images = await Future.wait(result.map((pattern) async {
        final file = File('${dir.path}/pattern_${pattern.id}.png');
        return await file.exists() ? file : File('');
      }));

      if (!mounted) return; // [ADDED]
      setState(() {
        patterns = result;
        previewImages = images;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('패턴 불러오기 실패: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ 서버 패턴 로딩 실패: ${e.toString()}')),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  // [ADDED] 패턴 생성 화면으로 이동한 뒤, 성공 시 목록 새로고침
  Future<void> _navigateToCreatePattern() async {
    try {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ChartNewScreen()),
      );

      // ChartNewScreen이 무엇을 반환하든(예: true, 생성된 id, json 등),
      // null만 아니면 생성된 것으로 보고 새로고침
      if (!mounted) return;
      if (result != null) {
        await _fetchPatterns();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ 패턴이 생성되었습니다.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('패턴 생성 중 오류가 발생했어요. ($e)')),
      );
    }
  }

  Future<void> _openDetail(Pattern pattern, File preview) async {
    try {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PatternDetailPage(
            pattern: pattern,
            imageFile: preview,
          ),
        ),
      );
      // 상세에서 수정/삭제가 이루어졌을 수 있으니 돌아오면 새로고침
      if (!mounted) return; // [ADDED]
      await _fetchPatterns(); // [ADDED]
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('상세 화면을 여는 중 오류가 발생했어요. ($e)')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final body = isLoading
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
      itemCount: patterns.length,
      itemBuilder: (context, index) {
        final pattern = patterns[index];
        final preview = index < previewImages.length
            ? previewImages[index]
            : File('');

        return Card(
          margin: const EdgeInsets.all(8),
          child: ListTile(
            leading: (preview.path.isNotEmpty && preview.existsSync())
                ? Image.file(
              preview,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            )
                : const SizedBox(
              width: 100,
              height: 100,
              child: Icon(Icons.image_not_supported),
            ),
            title: Text(pattern.patternName),
            subtitle: Text(
              '오차 ${pattern.tolerance}, 기간 ${pattern.periodValue} ${pattern.periodUnit}',
            ),
            onTap: () => _openDetail(pattern, preview),
          ),
        );
      },
    );

    return Scaffold(
      appBar: AppBar(title: const Text('서버 패턴 목록')),
      body: body,

      // [ADDED] 패턴 추가 버튼
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreatePattern,
        child: const Icon(Icons.add),
      ),
    );
  }
}
