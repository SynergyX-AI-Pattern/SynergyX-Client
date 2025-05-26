import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'search_screen.dart';



/// Computes the Dynamic Time Warping (DTW) distance between two lists of doubles.
double computeDTW(List<double> a, List<double> b) {
  int n = a.length;
  int m = b.length;
  List<List<double>> dp = List.generate(n + 1, (_) => List.filled(m + 1, double.infinity));
  dp[0][0] = 0;

  for (int i = 1; i <= n; i++) {
    for (int j = 1; j <= m; j++) {
      double cost = (a[i - 1] - b[j - 1]).abs();
      dp[i][j] = cost + [dp[i - 1][j], dp[i][j - 1], dp[i - 1][j - 1]].reduce(min);
    }
  }

  return dp[n][m];
}

/// Converts a list of Offset points into normalized Y-values (0.0 to 1.0) for DTW comparison.
List<double> normalizeYPoints(List<Offset> points, double maxHeight) {
  return points.map((e) => 1.0 - (e.dy / maxHeight)).toList();
}


Future<List<Offset>> loadPatternPointsFromJson(File jsonFile) async {
  final content = await jsonFile.readAsString();
  final data = jsonDecode(content);
  final List<dynamic> pointsData = data['points'];
  return pointsData.map((p) => Offset(p['x'].toDouble(), p['y'].toDouble())).toList();
}

/// Compares user pattern with stock chart segments and returns DTW matches below a threshold.
Future<List<int>> findMatchingSegments({
  required List<double> chartData,
  required List<double> pattern,
  required double threshold,
}) async {
  List<int> matchingIndices = [];
  int windowSize = pattern.length;

  for (int i = 0; i <= chartData.length - windowSize; i++) {
    List<double> segment = chartData.sublist(i, i + windowSize);
    double distance = computeDTW(pattern, segment);
    if (distance < threshold) {
      matchingIndices.add(i);
    }
  }

  return matchingIndices;
}

/// Simulates real-time data and triggers callback when a pattern match is detected.
void monitorLiveChart({
  required Stream<List<double>> liveChartStream,
  required List<double> pattern,
  required double threshold,
  required void Function(int index, double score) onMatch,
}) {
  int windowSize = pattern.length;

  liveChartStream.listen((data) {
    if (data.length >= windowSize) {
      List<double> segment = data.sublist(data.length - windowSize);
      double distance = computeDTW(pattern, segment);
      if (distance < threshold) {
        onMatch(data.length - windowSize, distance);
      }
    }
  });
}

class PatternDetailPage extends StatelessWidget {
  final String patternJson;
  final File imageFile;

  const PatternDetailPage({super.key, required this.patternJson, required this.imageFile});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> data = jsonDecode(patternJson);
    final interval = data['interval'].toString();
    final tolerance = double.parse(data['tolerance'].toString());

    return Scaffold(
      appBar: AppBar(
        title: const Text('패턴 상세 보기'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('삭제 확인'),
                  content: const Text('이 패턴을 삭제하시겠습니까?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext, false),
                      child: const Text('취소'),
                    ),
                    TextButton(
                      onPressed: () async {
                        Navigator.pop(dialogContext, true);

                        final ts = data['timestamp'];
                        final dir = await getApplicationDocumentsDirectory();
                        final imageFile = File('${dir.path}/pattern_$ts.png');
                        final jsonFile = File('${dir.path}/pattern_$ts.json');

                        await Future.wait([
                          if (await imageFile.exists()) imageFile.delete(),
                          if (await jsonFile.exists()) jsonFile.delete(),
                        ]);

                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context, true);
                          }
                        });
                      },
                      child: const Text('삭제'),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                final ts = data['timestamp'];
                final dir = await getApplicationDocumentsDirectory();
                final imageFile = File('${dir.path}/pattern_$ts.png');
                final jsonFile = File('${dir.path}/pattern_$ts.json');

                await Future.wait([
                  if (await imageFile.exists()) imageFile.delete(),
                  if (await jsonFile.exists()) jsonFile.delete(),
                ]);

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context, true);
                  }
                });
              }
            },
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: imageFile.existsSync() ? Image.file(imageFile, fit: BoxFit.contain)
                  : const Center(child: Icon(Icons.image_not_supported, size: 50)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('적용 종목: '),
                    const SizedBox(width: 12),
                    (data['stocks'] != null && data['stocks'] is List && (data['stocks'] as List).isNotEmpty)
                        ? Wrap(
                        spacing: 8,
                        children: List<Widget>.from((data['stocks'] as List).map((s) => Chip(label: Text(s), onDeleted: () async {
                          final ts = data['timestamp'];
                          final updatedData = jsonDecode(await File('${(await getApplicationDocumentsDirectory()).path}/pattern_${data['timestamp']}.json').readAsString());
                          if (updatedData['stocks'] == null || updatedData['stocks'] is! List) {
                            updatedData['stocks'] = [];
                          }
                          final stock = s.toString();
                          final current = List<String>.from(updatedData['stocks']);
                          current.remove(stock);
                          updatedData['stocks'] = current;

                          final file = File('${(await getApplicationDocumentsDirectory()).path}/pattern_$ts.json');
                          await file.writeAsString(jsonEncode(updatedData));

                          if (!context.mounted) return;
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PatternDetailPage(patternJson: jsonEncode(updatedData), imageFile: imageFile),
                            ),
                          );
                        })))
                    )
                        : const Text('없음'),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const StockSearchPage(),
                          ),
                        );
                        if (result != null && result is String) {
                          final updatedData = Map<String, dynamic>.from(data);
                          if (updatedData['stocks'] == null || updatedData['stocks'] is! List) {
                            updatedData['stocks'] = [];
                          }
                          final current = List<String>.from(updatedData['stocks']);
                          if (!current.contains(result)) {
                            current.add(result);
                          }
                          updatedData['stocks'] = current;                          final dir = await getApplicationDocumentsDirectory();
                          final ts = data['timestamp'];
                          final file = File('${dir.path}/pattern_$ts.json');
                          await file.writeAsString(jsonEncode(updatedData));

                          if (!context.mounted) return;
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PatternDetailPage(patternJson: jsonEncode(updatedData), imageFile: imageFile),
                            ),
                          );
                        }
                      },
                      child: const Text('종목 변경'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text('시간 간격: ${interval.toString()}분', style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                Text('오차 범위: ${(tolerance * 100).toStringAsFixed(0)}%', style: const TextStyle(fontSize: 16)),
              ],
            ),
          )
        ],
      ),
    );
  }
}

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
      MaterialPageRoute(builder: (context) => const InteractiveGridGraph()),
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
      appBar: AppBar(title: const Text('패턴 목록')),
      body: ListView.builder(
        itemCount: previewImages.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PatternDetailPage(
                    patternJson: savedPatterns[index],
                    imageFile: previewImages[index],
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
                child: previewImages[index].existsSync()
                    ? Image.file(previewImages[index], fit: BoxFit.cover)
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
  final GlobalKey _repaintKey = GlobalKey();
  String selectedStock = '';
  late int timestamp;

  @override
  void initState() {
    super.initState();
    timestamp = DateTime.now().millisecondsSinceEpoch;
    _initializePoints();
  }

  void _initializePoints() {
    // 초기에는 첫번째와 마지막 점만 포함
    points = [
      Offset(0, spacing * 6),
      Offset((gridSize - 1) * spacing, spacing * 6),
    ];
  }

  Future<void> _captureAndSaveImage() async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));

      final boundary = _repaintKey.currentContext?.findRenderObject();
      if (boundary is! RenderRepaintBoundary) {
        debugPrint('RepaintBoundary not found or not ready.');
        return;
      }

      if (boundary.debugNeedsPaint) {
        await Future.delayed(const Duration(milliseconds: 100));
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/pattern_$timestamp.png');
      await file.writeAsBytes(pngBytes);
    } catch (e, stackTrace) {
      debugPrint('이미지 저장 실패: $e');
      debugPrint('StackTrace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('이미지 저장에 실패했습니다.')),
        );
      }
    }
  }

  void _savePattern() async {
    final jsonData = {
      'timestamp': timestamp,
      'interval': interval,
      'tolerance': tolerance,
      'points': points.map((e) => {'x': e.dx, 'y': e.dy}).toList(),
      'stock': selectedStock,
    };

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/pattern_$timestamp.json');
    await file.writeAsString(jsonEncode(jsonData));

    await _captureAndSaveImage();

    if (!mounted) return;
    Navigator.pop(context, jsonEncode(jsonData));
  }

  @override
  Widget build(BuildContext context) {
    final double canvasSize = spacing * (gridSize - 1);

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
                      const SizedBox(height: 12),
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
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(gridSize, (i) {
                      return Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              final existing = points.where((p) => p.dx == i * spacing).length;
                              if (existing < 2 && points.length < 14) {
                                setState(() {
                                  points.add(Offset(i * spacing, spacing * (gridSize - 1)));
                                  points.sort((a, b) => a.dx.compareTo(b.dx));
                                });
                              }
                            },
                            child: const Text("➕", style: TextStyle(fontSize: 20)),
                          ),
                          const SizedBox(height: 4),
                          GestureDetector(
                            onTap: () {
                              final columnPoints = points.where((p) => p.dx == i * spacing).toList();
                              final isFirstColumn = i == 0;
                              final isLastColumn = i == gridSize - 1;
                              final mustKeepAtLeastOne = isFirstColumn || isLastColumn;
                              if (columnPoints.length > (mustKeepAtLeastOne ? 1 : 0)) {
                                setState(() {
                                  points.remove(columnPoints.last);
                                });
                              }
                            },
                            child: const Text("➖", style: TextStyle(fontSize: 20)),
                          ),
                        ],
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Center(
                          child: SizedBox(
                            width: canvasSize,
                            height: canvasSize,
                            child: RepaintBoundary(
                              key: _repaintKey,
                              child: GestureDetector(
                                onPanStart: (details) {
                                  final localPos = details.localPosition;
                                  for (int i = 0; i < points.length; i++) {
                                    if ((points[i] - localPos).distance < 15) {
                                      setState(() {
                                        selectedIndex = i;
                                      });
                                      break;
                                    }
                                  }
                                },
                                onPanUpdate: (details) {
                                  if (selectedIndex != null) {
                                    final localPos = details.localPosition;
                                    final fixedX = points[selectedIndex!].dx;
                                    final clampedY = localPos.dy.clamp(0.0, spacing * (gridSize - 1));
                                    final snappedY = (clampedY / spacing).round() * spacing;

                                    setState(() {
                                      points[selectedIndex!] = Offset(fixedX, snappedY);
                                    });
                                  }
                                },
                                onPanEnd: (_) => setState(() => selectedIndex = null),
                                child: Stack(
                                  children: [
                                    CustomPaint(
                                      size: Size(canvasSize, canvasSize),
                                      painter: GridPainter(
                                        points: points,
                                        gridSize: gridSize,
                                        spacing: spacing,
                                        selectedIndex: selectedIndex,
                                      ),
                                    ),

                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                ],
              ),
            ),
          ]
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
