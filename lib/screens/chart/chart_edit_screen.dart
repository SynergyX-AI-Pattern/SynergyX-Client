// chart_edit_screen.dart

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
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

  int? periodValue;
  String? periodUnit;

  late double tolerance;

  int? selectedIndex;

  static const List<int> _periodOptions = [3, 5, 7, 15, 30, 60];
  static const List<String> _unitOptions = ['HOUR', 'DAY'];
  static const List<double> _toleranceOptions = [0.1, 0.2, 0.5, 0.8, 1.0];

  double _snapTolerance(dynamic raw) {
    double x;
    if (raw is num) {
      x = raw.toDouble();
    } else if (raw is String) {
      x = double.tryParse(raw) ?? 1.0;
    } else {
      x = 1.0;
    }
    double best = _toleranceOptions.first;
    double bestDiff = (x - best).abs();
    for (final v in _toleranceOptions) {
      final d = (x - v).abs();
      if (d < bestDiff) {
        best = v;
        bestDiff = d;
      }
    }
    return best;
  }

  @override
  void initState() {
    super.initState();
    final data = widget.patternData;

    patternName = data['title'] ?? 'Pattern_${DateTime.now().millisecondsSinceEpoch}';

    final pvRaw = data['periodValue'];
    final int? pv = (pvRaw is int) ? pvRaw : (pvRaw is String ? int.tryParse(pvRaw) : null);
    periodValue = [3, 5, 7, 15, 30, 60].contains(pv) ? pv ?? 15 : 15;

    final puRaw = (data['periodUnit'] ?? 'DAY').toString().toUpperCase();
    periodUnit = (puRaw == 'HOUR' || puRaw == 'DAY') ? puRaw : 'DAY';

    tolerance = _snapTolerance(data['tolerance']);

    final rawPoints = List<num>.from(data['points'] ?? []);
   final double xStep = rawPoints.length > 1
        ? (spacing * (gridSize - 1)) / (rawPoints.length - 1)
        : spacing * (gridSize - 1);
    points = List.generate(
      rawPoints.length,
          (i) => Offset(
        i * xStep,
        (rawPoints[i].toDouble() * spacing),
      ),
    );
  }

  void _updatePattern() async {
    points.sort((a, b) => a.dx.compareTo(b.dx));
    final convertedPoints = points.map((p) => (p.dy ~/ spacing)).toList();
    final id = widget.patternData['id'];

    final request = PatternRequest(
      patternId: id,
      patternName: patternName,
      points: convertedPoints,
      tolerance: tolerance,
      periodValue: periodValue ?? _periodOptions.first, // 미선택이면 3 등 기본
      periodUnit: periodUnit ?? _unitOptions.last,      // 미선택이면 'DAY'
    );

    try {
      final body = request.toJson();
      debugPrint('➡️ updatePattern body=$body');  // 요청 JSON 확인
      await PatternApi.updatePattern(id, request);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ 패턴이 수정되었습니다.')),
      );
      final updated = await widget.onSaved();
      if (!mounted) return;
      Navigator.pop(context, updated);
    } catch (e) {
      if (e is DioException) {
        debugPrint('❌ status=${e.response?.statusCode}');
        debugPrint('❌ error body=${e.response?.data}'); // 서버 응답 찍기
      }
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
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, title: const Text('패턴 수정')),
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
                      isExpanded: false,
                      value: (_periodOptions.contains(periodValue)) ? periodValue : null,
                      hint: const Text('값 선택'),
                      items: _periodOptions
                          .map((e) => DropdownMenuItem<int>(
                        value: e,
                        child: Text('$e'),
                      ))
                          .toList(),
                      onChanged: (val) => setState(() => periodValue = val),
                    ),
                    const SizedBox(width: 12),
                    DropdownButton<String>(
                      isExpanded: false,
                      value: (_unitOptions.contains(periodUnit)) ? periodUnit : null,
                      hint: const Text('단위 선택'),
                      items: const [
                        DropdownMenuItem(value: 'HOUR', child: Text('시간')),
                        DropdownMenuItem(value: 'DAY', child: Text('일')),
                      ],
                      onChanged: (val) => setState(() => periodUnit = val),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('오차 범위: '),
                    const SizedBox(width: 12),
                    DropdownButton<double>(
                      value: _toleranceOptions.contains(tolerance) ? tolerance : null,
                      hint: const Text('선택'),
                      items: _toleranceOptions
                          .map((e) => DropdownMenuItem<double>(
                        value: e,
                        child: Text('${(e * 100).toStringAsFixed(0)}%'),
                      ))
                          .toList(),
                      onChanged: (val) => setState(() => tolerance = val ?? tolerance),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    side: const BorderSide(color: Colors.black12),
                  ),
                  onPressed: _updatePattern,
                  child: const Text('패턴 수정'),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                // 각 열별로 점을 추가/삭제할 수 있는 버튼들
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(gridSize, (i) {
                    return Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            final targetX = i * spacing;
                            final existing =
                                points.where((p) => (p.dx - targetX).abs() < 0.1).length;
                            if (existing < 2 && points.length < gridSize * 2) {
                              setState(() {
                                points.add(Offset(targetX, spacing * (gridSize - 1)));
                                points.sort((a, b) => a.dx.compareTo(b.dx));
                              });
                            }
                          },
                          child: const Text('➕', style: TextStyle(fontSize: 20)),
                        ),
                        const SizedBox(height: 4),
                        GestureDetector(
                          onTap: () {
                            final targetX = i * spacing;
                            final columnPoints = points
                                .where((p) => (p.dx - targetX).abs() < 0.1)
                                .toList();
                            final isFirst = i == 0;
                            final isLast = i == gridSize - 1;
                            final mustKeep = isFirst || isLast;
                            if (columnPoints.length > (mustKeep ? 1 : 0)) {
                              setState(() {
                                points.remove(columnPoints.last);
                              });
                            }
                          },
                          child: const Text('➖', style: TextStyle(fontSize: 20)),
                        ),
                      ],
                    );
                  }),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Center(
                    child: SizedBox(
                      width: canvasSize,
                      height: canvasSize,
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
                            final clampedY =
                            local.dy.clamp(0.0, spacing * (gridSize - 1));
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
