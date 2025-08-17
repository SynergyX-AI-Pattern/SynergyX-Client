// chart_edit_screen.dart

import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stockapp/data/pattern_api.dart';

class ChartEditPage extends StatefulWidget {
  final Map<String, dynamic> patternData;
  final Future<Map<String, dynamic>> Function() onSaved; // 수정 후 데이터를 돌려줄 콜백

  const ChartEditPage({
    super.key,
    required this.patternData,
    required this.onSaved,
  });

  @override
  State<ChartEditPage> createState() => _ChartEditScreenState();
}

class _ChartEditScreenState extends State<ChartEditPage> {
  final int gridSize = 7;
  final double spacing = 50;
  late List<Offset> points;
  late String patternName;
  late int periodValue;
  late String periodUnit;
  late double tolerance;
  late int patternId; // 기존 패턴의 ID (이미지 파일명과 매칭)
  final GlobalKey _repaintKey = GlobalKey();
  int? selectedIndex;

  @override
  void initState() {
    super.initState();
    final data = widget.patternData;
    patternId = data['id'];
    patternName = data['title'] ?? 'Pattern_$patternId';
    periodValue = data['periodValue'] ?? 15;
    periodUnit = (data['periodUnit'] ?? 'DAY').toUpperCase();
    tolerance = data['tolerance']?.toDouble() ?? 1.0;

    final rawPoints = List.from(data['points'] ?? []);
    points = List.generate(
      rawPoints.length,
          (i) => Offset(i * spacing, (rawPoints[i] as int) * spacing),
    );
  }

  // 패턴 ID를 기반으로 수정된 이미지를 저장
  Future<void> _captureAndSaveImage(int patternId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      final boundary = _repaintKey.currentContext?.findRenderObject();
      if (boundary is! RenderRepaintBoundary) return;
      if (boundary.debugNeedsPaint) await Future.delayed(const Duration(milliseconds: 100));
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/pattern_${patternId}.png');
      await file.writeAsBytes(pngBytes);
    } catch (e) {
      debugPrint('이미지 저장 실패: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('이미지 저장에 실패했습니다.')),
        );
      }
    }
  }

  void _updatePattern() async {
    final convertedPoints = points.map((p) => (p.dy ~/ spacing)).toList();
    final id = widget.patternData['id'];

    final request = PatternRequest(
      id: id,
      patternName: patternName,
      points: convertedPoints,
      tolerance: tolerance,
      periodValue: periodValue,
      periodUnit: periodUnit,
    );

    try {
      await PatternApi.updatePattern(id, request); // 서버에 수정 요청
      await _captureAndSaveImage(id); // 로컬 이미지도 갱신

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ 패턴이 수정되었습니다.')),
      );
      // 수정된 패턴 정보를 전달하여 상세 화면 갱신
      final updated = await widget.onSaved();
      Navigator.pop(context, updated);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ 수정 실패: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final canvasSize = spacing * (gridSize - 1);

    return Scaffold(
      appBar: AppBar(title: const Text('패턴 수정')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                TextFormField(
                  initialValue: patternName,
                  decoration: const InputDecoration(labelText: '패턴 이름'),
                  onChanged: (val) => setState(() => patternName = val),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('기간: '),
                    const SizedBox(width: 12),
                    DropdownButton<int>(
                      value: periodValue,
                      items: [3, 5, 7, 15, 30, 60]
                          .map((e) => DropdownMenuItem(value: e, child: Text('$e')))
                          .toList(),
                      onChanged: (val) => setState(() => periodValue = val!),
                    ),
                    const SizedBox(width: 12),
                    DropdownButton<String>(
                      value: periodUnit,
                      items: [
                        DropdownMenuItem(value: 'HOUR', child: Text('시간')),
                        DropdownMenuItem(value: 'DAY', child: Text('일')),
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
                          .map((e) => DropdownMenuItem(
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
                  onPressed: _updatePattern,
                  child: const Text('패턴 수정'),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: SizedBox(
                width: canvasSize,
                height: canvasSize,
                child: RepaintBoundary(
                  key: _repaintKey,
                  child: GestureDetector(
                    onPanStart: (details) {
                      final local = details.localPosition;
                      for (int i = 0; i < points.length; i++) {
                        if ((points[i] - local).distance < 15) {
                          setState(() => selectedIndex = i);
                          break;
                        }
                      }
                    },
                    onPanUpdate: (details) {
                      if (selectedIndex != null) {
                        final local = details.localPosition;
                        final fixedX = points[selectedIndex!].dx;
                        final clampedY = local.dy.clamp(0.0, spacing * (gridSize - 1));
                        final snappedY = (clampedY / spacing).round() * spacing;
                        setState(() {
                          points[selectedIndex!] = Offset(fixedX, snappedY);
                        });
                      }
                    },
                    onPanEnd: (_) => setState(() => selectedIndex = null),
                    child: CustomPaint(
                      size: Size(canvasSize, canvasSize),
                      painter: GridPainter(
                        points: points,
                        gridSize: gridSize,
                        spacing: spacing,
                        selectedIndex: selectedIndex,
                      ),
                    ),
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
      final offset = i * spacing;
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
