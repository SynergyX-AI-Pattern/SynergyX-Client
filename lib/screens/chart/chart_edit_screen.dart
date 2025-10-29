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

  static const List<String> _unitOptions = ['HOUR', 'DAY'];
  static const int _minHourValue = 1;
  static const int _maxHourValue = 24;
  static const int _maxDayValue = 31;
  static final List<double> _toleranceOptions = List<double>.generate(
    20,
        (index) => double.parse(((index + 1) * 0.05).toStringAsFixed(2)),
  );

  String _formatToleranceLabel(double value) {
    var text = value.toStringAsFixed(2);
    if (text.contains('.')) {
      while (text.endsWith('0')) {
        text = text.substring(0, text.length - 1);
      }
      if (text.endsWith('.')) {
        text = text.substring(0, text.length - 1);
      }
    }
    return text;
  }

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

  List<int> _periodOptionsFor(String unit) {
    // 생성 화면과 동일한 규칙 적용 (시간은 7시간 이상)
    if (unit == 'HOUR') {
      return List<int>.generate(
        _maxHourValue - _minHourValue + 1,
            (index) => _minHourValue + index,
      );
    }
    return List<int>.generate(_maxDayValue, (index) => index + 1);
  }

  List<int> _periodDropdownValues(String unit, int? current) {
    // 이미 저장된 값이 목록에 없더라도 그대로 보여 주기 위해 병합한다.
    final merged = <int>[];
    if (current != null) {
      merged.add(current);
    }
    for (final option in _periodOptionsFor(unit)) {
      if (!merged.contains(option)) {
        merged.add(option);
      }
    }
    return merged;
  }

  bool _isDurationValid({required int pointCount}) {
    final unit = (periodUnit ?? 'DAY').toUpperCase();
    final value = periodValue ?? _periodOptionsFor(unit).first;
    final totalHoursPerStep = unit == 'HOUR' ? value : value * 24;
    final totalPatternHours = totalHoursPerStep * pointCount;
    return totalPatternHours >= 24;
  }

  Future<void> _showInvalidDurationDialog() async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('패턴 길이 확인'),
        content: const Text('기간 × 점 개수는 24시간 이상이어야 합니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    final data = widget.patternData;

    patternName = (data['patternName'] ?? data['title'] ??
        'Pattern_${DateTime.now().millisecondsSinceEpoch}')
        .toString();

    final pvRaw = data['periodValue'];
    final int? pv =
    (pvRaw is int) ? pvRaw : (pvRaw is String ? int.tryParse(pvRaw) : null);

    final puRaw = (data['periodUnit'] ?? 'DAY').toString().toUpperCase();
    periodUnit = (puRaw == 'HOUR' || puRaw == 'DAY') ? puRaw : 'DAY';

    final currentOptions = _periodOptionsFor(periodUnit!);
    // 기존에 저장된 값이 있으면 그대로 유지하여 화면에 노출한다.
    periodValue = pv ?? (currentOptions.isNotEmpty ? currentOptions.first : null);

    tolerance = _snapTolerance(data['tolerance']);

    final rawPoints = List<num>.from(data['points'] ?? []);
    final double xStep =
    rawPoints.length > 1
        ? (spacing * (gridSize - 1)) / (rawPoints.length - 1)
        : spacing * (gridSize - 1);
    points = List.generate(
      rawPoints.length,
          (i) => Offset(i * xStep, (rawPoints[i].toDouble() * spacing)),
    );
  }

  void _updatePattern() async {
    points.sort((a, b) => a.dx.compareTo(b.dx));
    final convertedPoints = points.map((p) => (p.dy ~/ spacing)).toList();
    final rawId = widget.patternData['patternId'] ?? widget.patternData['id'];
    final String rawIdStr = rawId == null ? '' : rawId.toString();
    final int id = rawId is int ? rawId : int.tryParse(rawIdStr) ?? 0;

    if (id == 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('패턴 정보를 확인할 수 없습니다.')),
      );
      return;
    }

    if (!_isDurationValid(pointCount: convertedPoints.length)) {
      await _showInvalidDurationDialog();
      return;
    }

    final request = PatternRequest(
      patternId: id,
      patternName: patternName,
      points: convertedPoints,
      tolerance: tolerance,
      periodValue: periodValue ?? _periodOptionsFor(periodUnit ?? 'DAY').first,
      // 미선택이면 기본값으로 전송
      periodUnit: periodUnit ?? _unitOptions.last, // 미선택이면 'DAY'
    );

    try {
      final body = request.toJson();
      debugPrint('➡️ updatePattern body=$body'); // 요청 JSON 확인
      await PatternApi.updatePattern(id, request);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('패턴이 수정되었습니다.')));
      final updated = await widget.onSaved();
      if (!mounted) return;
      Navigator.pop(context, updated);
    } catch (e) {
      if (e is DioException) {
        debugPrint('❌ status=${e.response?.statusCode}');
        debugPrint('❌ error body=${e.response?.data}'); // 서버 응답 찍기
      }
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('❌ 수정 실패: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final canvasSize = spacing * (gridSize - 1);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          '패턴 수정',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                // 패턴 이름 수정 입력 필드
                TextFormField(
                  initialValue: patternName,
                  decoration: const InputDecoration(
                    labelText: '패턴 이름',
                    labelStyle: TextStyle(fontSize: 18,
                        fontWeight: FontWeight.bold), // labelText 크기 키우기
                  ),
                  onChanged: (val) => setState(() => patternName = val),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('기간: '),
                    const SizedBox(width: 12),
                    DropdownButton<int>(
                      isExpanded: false,
                      dropdownColor: Colors.white,
                      value: periodValue,
                      hint: const Text('값 선택'),
                      items: _periodDropdownValues(periodUnit ?? 'DAY', periodValue)
                          .map(
                            (e) => DropdownMenuItem<int>(
                          value: e,
                          child: Text('$e'),
                        ),
                      )
                          .toList(),
                      onChanged: (val) => setState(() => periodValue = val),
                    ),
                    const SizedBox(width: 12),
                    DropdownButton<String>(
                      dropdownColor: Colors.white,
                      isExpanded: false,
                      value: (_unitOptions.contains(periodUnit))
                          ? periodUnit
                          : null,
                      hint: const Text('단위 선택'),
                      items: const [
                        DropdownMenuItem(value: 'HOUR', child: Text('시간')),
                        DropdownMenuItem(value: 'DAY', child: Text('일')),
                      ],
                      onChanged: (val) {
                        if (val == null) return;
                        setState(() {
                          // 단위만 교체하고 값은 유지하여 사용자가 저장된 수치를 확인할 수 있게 한다.
                          periodUnit = val;
                          if (periodValue == null) {
                            final newOptions = _periodOptionsFor(val);
                            periodValue =
                            newOptions.isNotEmpty ? newOptions.first : null;
                          }
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('오차 범위: '),
                    const SizedBox(width: 12),
                    DropdownButton<double>(
                      value: _toleranceOptions.contains(tolerance)
                          ? tolerance
                          : null,
                      hint: const Text('선택'),
                      dropdownColor: Colors.white,
                      items: _toleranceOptions.map((e) =>
                          DropdownMenuItem<double>(
                            value: e,
                            child: Text(_formatToleranceLabel(e)),
                          )).toList(),
                      onChanged: (val) =>
                          setState(() => tolerance = val ?? tolerance),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // 수정 버튼을 제일 아래로 배치
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2C2C2C),
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.black12),
                  ),
                  onPressed: _updatePattern,
                  child: const Text(
                    '저장',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
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
                            final targetX = i * spacing;
                            final existing = points
                                .where((p) => (p.dx - targetX).abs() < 0.1)
                                .length;
                            if (existing < 2 && points.length < gridSize * 2) {
                              setState(() {
                                points.add(
                                    Offset(targetX, spacing * (gridSize - 1)));
                                points.sort((a, b) => a.dx.compareTo(b.dx));
                              });
                            }
                          },
                          child: const Text(
                            '➕',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                        const SizedBox(height: 4),
                        GestureDetector(
                          onTap: () {
                            final targetX = i * spacing;
                            final columnPoints = points.where((p) =>
                            (p.dx - targetX).abs() < 0.1).toList();
                            final isFirst = i == 0;
                            final isLast = i == gridSize - 1;
                            final mustKeep = isFirst || isLast;
                            if (columnPoints.length > (mustKeep ? 1 : 0)) {
                              setState(() {
                                points.remove(columnPoints.last);
                              });
                            }
                          },
                          child: const Text(
                            '➖',
                            style: TextStyle(fontSize: 20),
                          ),
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
                            final clampedY = local.dy.clamp(
                                0.0, spacing * (gridSize - 1));
                            final snappedY = (clampedY / spacing).round() *
                                spacing;
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
    final gridPaint =
        Paint()
          ..color = Colors.grey
          ..strokeWidth = 1;

    for (int i = 0; i < gridSize; i++) {
      final offset = i * spacing;
      canvas.drawLine(
        Offset(offset, 0),
        Offset(offset, size.height),
        gridPaint,
      );
      canvas.drawLine(Offset(0, offset), Offset(size.width, offset), gridPaint);
    }

    final linePaint =
        Paint()
          ..color = Colors.blue
          ..strokeWidth = 2;
    for (int i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i], points[i + 1], linePaint);
    }

    for (int i = 0; i < points.length; i++) {
      final paint =
          Paint()..color = (i == selectedIndex) ? Colors.green : Colors.orange;
      canvas.drawCircle(points[i], (i == selectedIndex) ? 8 : 5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
