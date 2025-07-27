import 'dart:ui' as ui;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stockapp/models/pattern.dart';
import 'package:stockapp/services/api_service.dart';


class ChartNewScreen extends StatefulWidget {
  const ChartNewScreen({super.key});

  @override
  State<ChartNewScreen> createState() => _ChartNewScreenState();
}

class _ChartNewScreenState extends State<ChartNewScreen> {
  final int gridSize = 7;
  final double spacing = 50;
  late List<Offset> points;
  int? selectedIndex;
  double tolerance = 1.0;
  int periodValue = 15;
  String periodUnit = 'minute';
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
    points = [
      Offset(0, spacing * 6),
      Offset((gridSize - 1) * spacing, spacing * 6),
    ];
  }

  Future<void> _captureAndSaveImage() async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      final boundary = _repaintKey.currentContext?.findRenderObject();
      if (boundary is! RenderRepaintBoundary) return;
      if (boundary.debugNeedsPaint) await Future.delayed(const Duration(milliseconds: 100));
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
    final patternName = 'Pattern_$timestamp';

    final convertedPoints = points.map((p) => (p.dy ~/ spacing)).toList();

    final request = PatternRequest(
      patternName: patternName,
      points: convertedPoints,
      tolerance: tolerance,
      periodValue: periodValue,
      periodUnit: periodUnit,
    );

    try {
      await ApiService.sendPatternToServer(request);
      await _captureAndSaveImage();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ 패턴이 서버에 저장되었습니다!')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ 저장 실패: ${e.toString()}')),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    final double canvasSize = spacing * (gridSize - 1);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, title: const Text('패턴 설정')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    const Text('기간: '),
                    const SizedBox(width: 12),
                    DropdownButton<int>(
                      value: periodValue,
                      items: [3, 5, 7, 15, 30, 60].map((e) => DropdownMenuItem(
                        value: e,
                        child: Text('$e'),
                      )).toList(),
                      onChanged: (val) => setState(() => periodValue = val!),
                    ),
                    const SizedBox(width: 12),
                    DropdownButton<String>(
                      value: periodUnit,
                      items: [
                        DropdownMenuItem(value: 'sec', child: Text('초')),
                        DropdownMenuItem(value: 'minute', child: Text('분')),
                        DropdownMenuItem(value: 'hour', child: Text('시')),
                        DropdownMenuItem(value: 'day', child: Text('일')),
                        DropdownMenuItem(value: 'month', child: Text('월')),
                      ],
                      onChanged: (val) => setState(() => periodUnit = val!),
                    )
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
                                    setState(() => selectedIndex = i);
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
