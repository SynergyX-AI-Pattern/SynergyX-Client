import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stockapp/screens/chart_new_screen.dart';
import 'package:stockapp/screens/chart_detail_screen.dart';

class ChartScreen extends StatelessWidget {
  const ChartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: PatternListPage(),
    );
  }
}

class PatternListPage extends StatefulWidget {
  const PatternListPage({super.key});

  @override
  State<PatternListPage> createState() => _PatternListPageState();
}

class _PatternListPageState extends State<PatternListPage> {
  List<Map<String, dynamic>> serverPatterns = [];

  List<String> savedPatterns = [];
  List<File> previewImages = [];

  @override
  void initState() {
    super.initState();
    _loadSavedPatterns();
  }

  Future<void> _loadSavedPatterns() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/pattern_list.json');
    if (await file.exists()) {
      final content = await file.readAsString();
      final patterns = List<String>.from(jsonDecode(content));

      final previews = <File>[];
      for (var p in patterns) {
        final json = jsonDecode(p);
        final ts = json['timestamp'];
        final imgFile = File('${dir.path}/pattern_$ts.png');
        if (await imgFile.exists()) {
          previews.add(imgFile);
        } else {
          previews.add(File(''));
        }
      }

      setState(() {
        savedPatterns = patterns;
        previewImages = previews;
      });
    }
  }

  Future<void> _savePatternList() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/pattern_list.json');
    await file.writeAsString(jsonEncode(savedPatterns));
  }

  void _navigateToCreatePattern() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ChartNewScreen()),
    );
    if (result != null) {
      final json = jsonDecode(result);
      final ts = json['timestamp'];
      final dir = await getApplicationDocumentsDirectory();
      final imgFile = File('${dir.path}/pattern_$ts.png');

      setState(() {
        savedPatterns.add(result);
        previewImages.add(imgFile);
      });
      _savePatternList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('패턴 목록'),
      ),
      body: ListView.builder(
        itemCount: savedPatterns.length,
        itemBuilder: (context, index) {
          final preview = previewImages[index];
          return GestureDetector(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PatternDetailPage(
                    patternJson: savedPatterns[index],
                    imageFile: preview,
                  ),
                ),
              );
              if (result == true) {
                setState(() {
                  savedPatterns.removeAt(index);
                  previewImages.removeAt(index);
                });
                _savePatternList();
              }
            },
            child: Card(
              margin: const EdgeInsets.all(8.0),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: preview.existsSync()
                    ? Image.file(preview, fit: BoxFit.cover)
                    : const Icon(Icons.image_not_supported, size: 50),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreatePattern,
        child: const Icon(Icons.add),
      ),
    );
  }
}
