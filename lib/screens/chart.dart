import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
  List<String> savedPatterns = [];

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
      setState(() {
        savedPatterns = List<String>.from(jsonDecode(content));
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
      MaterialPageRoute(builder: (context) => const InteractiveGridGraph()),
    );
    if (result != null) {
      setState(() {
        savedPatterns.add(result);
      });
      _savePatternList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('패턴 목록')),
      body: ListView.builder(
        itemCount: savedPatterns.length,
        itemBuilder: (context, index) => ListTile(
          title: Text('패턴 ${index + 1}'),
          subtitle: Text(savedPatterns[index]),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreatePattern,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class InteractiveGridGraph extends StatefulWidget {
  const InteractiveGridGraph({super.key});

  @override
  State<InteractiveGridGraph> createState() => _InteractiveGridGraphState();
}

class _InteractiveGridGraphState extends State<InteractiveGridGraph> {
  final int gridSize = 7;
  final double spacing = 50;
  late List<Offset> points;
  int? selectedIndex;
  double interval = 1.0;
  double tolerance = 1.0;

  @override
  void initState() {
    super.initState();
    _initializePoints();
  }

  void _initializePoints() {
    points = List.generate(
      7,
          (i) => Offset(i * spacing, spacing * 6), // x축 시간, y축 100%에서 시작
    );
  }

  void _savePattern() {
    final jsonData = {
      'interval': interval,
      'tolerance': tolerance,
      'points': points.map((e) => {'x': e.dx, 'y': e.dy}).toList(),
    };

    getApplicationDocumentsDirectory().then((dir) async {
      final file = File('${dir.path}/pattern_${DateTime.now().millisecondsSinceEpoch}.json');
      await file.writeAsString(jsonEncode(jsonData));

      if (!mounted) return;
      Navigator.pop(context, jsonEncode(jsonData));
    });
  }

  @override
  Widget build(BuildContext context) {
    final double size = spacing * (gridSize - 1);

    return Scaffold(
      appBar: AppBar(title: const Text('패턴 설정')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    const Text('시간 간격: '),
                    const SizedBox(width: 12),
                    DropdownButton<double>(
                      value: interval,
                      items: List.generate(60, (index) => (index + 1).toDouble())
                          .map((e) => DropdownMenuItem<double>(
                        value: e,
                        child: Text('${e.toInt()}분'),
                      ))
                          .toList(),
                      onChanged: (val) => setState(() => interval = val!),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('오차 범위: '),
                    const SizedBox(width: 12),
                    DropdownButton<double>(
                      value: tolerance,
                      items: [0.1, 0.2, 0.5, 0.8, 1.0]
                          .map((e) => DropdownMenuItem<double>(
                        value: e,
                        child: Text('${(e * 100).toStringAsFixed(0)}%'),
                      ))
                          .toList(),
                      onChanged: (val) => setState(() => tolerance = val!),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _savePattern,
                  child: const Text('패턴 저장'),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: SizedBox(
                width: size,
                height: size,
                child: GestureDetector(
                  onPanStart: (details) {
                    final box = context.findRenderObject() as RenderBox;
                    final localPos = box.globalToLocal(details.globalPosition);

                    // GestureDetector 좌표 → CustomPaint 좌표로 변환
                    final size = spacing * (gridSize - 1);
                    final Offset offsetToCenter = Offset(
                      (box.size.width - size) / 2,
                      (box.size.height - size) / 2,
                    );

                    final customPaintPos = localPos - offsetToCenter;

                    for (int i = 0; i < points.length; i++) {
                      if ((points[i] - customPaintPos).distance < 15) {
                        setState(() {
                          selectedIndex = i;
                        });
                        break;
                      }
                    }
                  },

                  onPanUpdate: (details) {
                    if (selectedIndex != null) {
                      final box = context.findRenderObject() as RenderBox;
                      final localPos = box.globalToLocal(details.globalPosition);

                      // GestureDetector 좌표 → CustomPaint 좌표로 변환
                      final size = spacing * (gridSize - 1);
                      final Offset offsetToCenter = Offset(
                        (box.size.width - size) / 2,
                        (box.size.height - size) / 2,
                      );

                      final customPaintPos = localPos - offsetToCenter;

                      final clampedY = customPaintPos.dy.clamp(0.0, spacing * 6).toDouble();

                      setState(() {
                        final dx = points[selectedIndex!].dx;
                        points[selectedIndex!] = Offset(dx, clampedY);

                        if (selectedIndex == 0) {
                          final baseY = clampedY;
                          for (int i = 0; i < points.length; i++) {
                            final newRelativeY =
                            (points[i].dy - baseY).clamp(0.0, spacing * 6).toDouble();
                            points[i] = Offset(points[i].dx, newRelativeY);
                          }
                          points[0] = Offset(dx, 0);
                        }
                      });
                    }
                  },

                  onPanEnd: (_) => setState(() => selectedIndex = null),
                  child: CustomPaint(
                    painter: GridPainter(
                      points: points,
                      gridSize: gridSize,
                      spacing: spacing,
                      selectedIndex: selectedIndex,
                    ),
                    size: Size(size, size),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}

class GridPainter extends CustomPainter {
  final List<Offset> points;
  final int gridSize;
  final double spacing;
  final int? selectedIndex;

  GridPainter({
    required this.points,
    required this.gridSize,
    required this.spacing,
    required this.selectedIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1;

    for (int i = 0; i < gridSize; i++) {
      double offset = i * spacing;
      canvas.drawLine(Offset(offset, 0), Offset(offset, size.height), gridPaint);
      canvas.drawLine(Offset(0, offset), Offset(size.width, offset), gridPaint);
    }

    final linePaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2;

    for (int i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i], points[i + 1], linePaint);
    }

    for (int i = 0; i < points.length; i++) {
      final paint = Paint()
        ..color = (i == selectedIndex) ? Colors.green : Colors.orange;
      canvas.drawCircle(points[i], (i == selectedIndex) ? 8 : 5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

