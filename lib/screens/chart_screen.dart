import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stockapp/data/pattern_api.dart';
import 'package:stockapp/models/pattern.dart';
import 'dart:convert';

import 'package:stockapp/screens/chart_detail_screen.dart';

class ChartScreen extends StatefulWidget {
  const ChartScreen({super.key});

  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  List<Pattern> patterns = [];
  List<File> previewImages = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPatterns();
  }

  Future<void> _fetchPatterns() async {
    try {
      final result = await PatternApi.getPatterns();

      final dir = await getApplicationDocumentsDirectory();
      final images = await Future.wait(result.map((pattern) async {
        final file = File('${dir.path}/pattern_${pattern.id}.png');
        return await file.exists() ? file : File('');
      }));

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('서버 패턴 목록')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: patterns.length,
        itemBuilder: (context, index) {
          final pattern = patterns[index];
          final preview = previewImages[index];

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PatternDetailPage(
                    patternJson: jsonEncode(pattern.toJson()),

                    imageFile: preview,
                  ),
                ),
              );
            },
            child: Card(
              margin: const EdgeInsets.all(8),
              child: Row(
                children: [
                  if (preview.existsSync())
                    Image.file(
                      preview,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    )
                  else
                    const SizedBox(
                      width: 100,
                      height: 100,
                      child: Icon(Icons.image_not_supported),
                    ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ListTile(
                      title: Text(pattern.patternName),
                      subtitle: Text(
                          '오차 ${pattern.tolerance}, 기간 ${pattern.periodValue} ${pattern.periodUnit}'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
