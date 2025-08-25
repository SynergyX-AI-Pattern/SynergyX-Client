import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:stockapp/data/pattern_api.dart';

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
  int? _selectedCol;

  // ===== 폼 값 =====
  double tolerance = 0.5;
  int periodValue = 15;
  String periodUnit = 'DAY'; // "HOUR" or "DAY"

  // ===== 메타 =====
  late int _timestamp;
  final TextEditingController _nameController = TextEditingController(
    text: "패턴1",
  );

  @override
  void initState() {
    super.initState();
    _timestamp = DateTime.now().millisecondsSinceEpoch;
    _initializePoints();
  }

  void _initializePoints() {
    // 시작은 좌/우 하단 한 개씩
    points = [
      Offset(0, spacing * (gridSize - 1)),
      Offset((gridSize - 1) * spacing, spacing * (gridSize - 1)),
    ];
  }

  // 열에 점 추가 (열당 최대 2개, 전체 14개 제한)
  void _addPointAtColumn(int col) {
    final x = col * spacing;
    final existing = points.where((p) => p.dx == x).length;
    if (existing >= 2 || points.length >= 14) return;

    setState(() {
      points.add(Offset(x, spacing * (gridSize - 1))); // 바닥에서 시작
      points.sort((a, b) => a.dx.compareTo(b.dx));
    });
  }

  // 열에서 마지막 점 삭제 (첫/끝 열은 최소 1개 유지)
  void _removeLastInColumn(int col) {
    final x = col * spacing;
    final columnPoints =
        points.where((p) => p.dx == x).toList()
          ..sort((a, b) => a.dy.compareTo(b.dy)); // 아래쪽(큰 y)부터 지우기
    if (columnPoints.isEmpty) return;

    final isEdge = (col == 0) || (col == gridSize - 1);
    if (isEdge && columnPoints.length <= 1) return;

    setState(() {
      points.remove(columnPoints.last);
    });
  }

  // 포인트 하나 삭제 (롱프레스용, 첫/끝 열 최소 1개 규칙 준수)
  void _removePointAt(int index) {
    final p = points[index];
    final col = (p.dx / spacing).round();
    final isEdge = (col == 0) || (col == gridSize - 1);
    final columnPoints =
        points.where((e) => (e.dx / spacing).round() == col).toList();
    if (isEdge && columnPoints.length <= 1) return;

    setState(() {
      points.removeAt(index);
    });
  }

  int? _pickNearestPoint(Offset localPos, {double radius = 22}) {
    int? pick;
    double best = double.infinity;
    for (int i = 0; i < points.length; i++) {
      final d = (points[i] - localPos).distance;
      if (d < radius && d < best) {
        best = d;
        pick = i;
      }
    }
    return pick;
  }

  // 페이지 탭 처리: 캔버스 밖이면 선택 해제
  final GlobalKey _canvasKey = GlobalKey();

  void _handlePageTapDown(TapDownDetails d) {
    final pos = d.globalPosition;
    final ctx = _canvasKey.currentContext;
    if (ctx == null) return;

    final box = ctx.findRenderObject() as RenderBox;
    final topLeft = box.localToGlobal(Offset.zero);
    final rect = Rect.fromLTWH(
      topLeft.dx,
      topLeft.dy,
      box.size.width,
      box.size.height,
    );

    // 캔버스 바깥을 누른 경우만 선택 해제
    if (!rect.contains(pos)) {
      FocusScope.of(context).unfocus(); // 키보드 닫기(이름/입력 필드 등)
      if (_selectedCol != null) {
        setState(() => _selectedCol = null);
      }
    }
  }

  Future<void> _savePattern() async {
    final id = DateTime.now().millisecondsSinceEpoch;
    final nameInput = _nameController.text.trim();
    final patternName =
        nameInput.isNotEmpty ? nameInput : 'Pattern_$_timestamp';

    // y를 0~6 정수로 저장(아랫줄이 6, 윗줄이 0)
    final convertedPoints = points.map((p) => (p.dy ~/ spacing)).toList();

    final request = PatternRequest(
      patternId: id,
      patternName: patternName,
      points: convertedPoints,
      tolerance: tolerance,
      periodValue: periodValue,
      periodUnit: periodUnit.toUpperCase(),
    );

    try {
      await PatternApi.createPattern(request);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('✅ 패턴이 서버에 저장되었습니다!')));
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('❌ 저장 실패: $e')));
    }
  }

  // 공통 인풋 데코레이션
  InputDecoration _inputDecoration({String? label}) => InputDecoration(
    labelText: label,
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Colors.black12),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final double canvasSize = spacing * (gridSize - 1);

    // 미니 FAB 위치 계산을 위한 x 좌표 (캔버스 내부 좌표)
    final double? selectedX =
        (_selectedCol != null) ? _selectedCol! * spacing : null;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0, // 변경: 그림자 제거
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTapDown: _handlePageTapDown, // ← 이미 추가했던: 캔버스 밖 탭 시 숨김
        child: NotificationListener<ScrollStartNotification>(
          onNotification: (notification) {
            // 스크롤이 시작되면 가이드/미니바 숨김 + 키보드 닫기
            if (_selectedCol != null) {
              setState(() => _selectedCol = null);
            }
            FocusScope.of(context).unfocus();
            return false; // 스크롤 동작은 그대로 전달
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 상단 이름 입력 (언더라인)
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: "패턴1",
                    border: UnderlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 12),

                // ===== 캔버스 컨테이너 (카드형) =====
                Center(
                  child: Container(
                    key: _canvasKey,

                    width: canvasSize + 24,
                    height: canvasSize + 36,
                    // 위쪽 미니 FAB 여유
                    padding: const EdgeInsets.fromLTRB(12, 24, 12, 12),
                    // 위쪽 공간 확보
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: Stack(
                      clipBehavior: Clip.none, // 변경: FAB가 상단으로 살짝 나가도 보이게
                      children: [
                        // 캔버스(그리드/라인/점)
                        Positioned.fill(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,

                            // 빈 영역도 터치 처리
                            onPanDown: (details) {
                              final i = _pickNearestPoint(
                                details.localPosition,
                              );
                              if (i != null) setState(() => selectedIndex = i);
                            },

                            onTapUp: (details) {
                              final local = details.localPosition;
                              int col = (local.dx / spacing).round().clamp(
                                0,
                                gridSize - 1,
                              );
                              setState(() => _selectedCol = col);
                            },

                            onPanStart: (details) {
                              final i = _pickNearestPoint(
                                details.localPosition,
                              );
                              if (i != null) setState(() => selectedIndex = i);
                            },

                            onPanUpdate: (details) {
                              if (selectedIndex != null) {
                                final localPos = details.localPosition;
                                final fixedX = points[selectedIndex!].dx;
                                final clampedY = localPos.dy.clamp(
                                  0.0,
                                  spacing * (gridSize - 1),
                                );
                                final snappedY =
                                    (clampedY / spacing).round() * spacing;
                                setState(() {
                                  points[selectedIndex!] = Offset(
                                    fixedX,
                                    snappedY,
                                  );
                                  _selectedCol =
                                      (fixedX / spacing)
                                          .round(); // 드래그 중인 열 강조 유지
                                });
                              }
                            },

                            onPanEnd:
                                (_) => setState(() => selectedIndex = null),

                            onLongPressStart: (details) {
                              final i = _pickNearestPoint(
                                details.localPosition,
                              );
                              if (i != null) _removePointAt(i);
                            },

                            child: CustomPaint(
                              painter: _GridPainter(
                                points: points,
                                gridSize: gridSize,
                                spacing: spacing,
                                selectedIndex: selectedIndex,
                                selectedColumn: _selectedCol,
                              ),
                            ),
                          ),
                        ),

                        // ===== 선택 열에만 뜨는 미니 + / - FAB =====
                        if (_selectedCol != null && selectedX != null)
                          Positioned(
                            left: selectedX - 16,
                            top: -18,
                            child: Column(
                              children: [
                                _MiniFab(
                                  icon: Icons.add,
                                  onTap: () => _addPointAtColumn(_selectedCol!),
                                ),
                                const SizedBox(height: 6),
                                _MiniFab(
                                  icon: Icons.remove,
                                  onTap:
                                      () => _removeLastInColumn(_selectedCol!),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ===== 하단 폼 (기간 / 단위 / 오차 범위) =====
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // 기간
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "기간",
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          DropdownButtonFormField<int>(
                            value: periodValue,
                            decoration: _inputDecoration(),
                            dropdownColor: Colors.white,
                            items:
                                (periodUnit == "HOUR"
                                        ? List.generate(
                                          23,
                                          (i) => i + 1,
                                        ) // 1~23
                                        : List.generate(
                                          30,
                                          (i) => i + 1,
                                        )) // 1~30
                                    .map(
                                      (e) => DropdownMenuItem(
                                        value: e,
                                        child: Text("$e"),
                                      ),
                                    )
                                    .toList(),
                            onChanged:
                                (v) => setState(
                                  () => periodValue = v ?? periodValue,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),

                    // 단위
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "단위",
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          DropdownButtonFormField<String>(
                            value: periodUnit,
                            decoration: _inputDecoration(),
                            dropdownColor: Colors.white,
                            items: const [
                              DropdownMenuItem(value: "HOUR", child: Text("분")),
                              DropdownMenuItem(value: "DAY", child: Text("일")),
                            ],
                            onChanged: (val) {
                              setState(() {
                                periodUnit = val ?? periodUnit;
                                periodValue = 1; // 단위 바꿀 때 기본값 리셋
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),

                    // 오차 범위
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "오차 범위",
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          TextFormField(
                            initialValue: tolerance.toString(),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: _inputDecoration(),
                            onChanged: (val) {
                              final parsed = double.tryParse(val);
                              if (parsed != null) {
                                setState(() => tolerance = parsed);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // 생성 버튼 (우측 정렬)
                Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    width: 100,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: _savePattern,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text("생성"),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ===== 캔버스 페인터 =====
class _GridPainter extends CustomPainter {
  final List<Offset> points;
  final int gridSize;
  final double spacing;
  final int? selectedIndex;
  final int? selectedColumn; // 변경: 선택 열 가이드를 위해 추가

  _GridPainter({
    required this.points,
    required this.gridSize,
    required this.spacing,
    required this.selectedIndex,
    required this.selectedColumn,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 그리드
    final gridPaint =
        Paint()
          ..color = const Color(0xFFE5E5E5)
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

    // 변경: 선택 열 가이드 (얇은 파란색)
    if (selectedColumn != null) {
      final x = selectedColumn! * spacing;
      final guidePaint =
          Paint()
            ..color = const Color(0xBCBFC3FF)
            ..strokeWidth = 2;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), guidePaint);
    }

    // 패턴 선
    final linePaint =
        Paint()
          ..color = const Color(0xFF1573FE)
          ..strokeWidth = 2;
    for (int i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i], points[i + 1], linePaint);
    }

    // 점
    for (int i = 0; i < points.length; i++) {
      final paint =
          Paint()
            ..color =
                (i == selectedIndex)
                    ? const Color(0xFF2ECC71)
                    : const Color(0xFFFFA500);
      canvas.drawCircle(points[i], (i == selectedIndex) ? 8 : 5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter old) {
    return old.points != points ||
        old.selectedIndex != selectedIndex ||
        old.selectedColumn != selectedColumn;
  }
}

// ===== 미니 FAB 위젯 =====
class _MiniFab extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _MiniFab({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      shape: const CircleBorder(),
      color: Colors.black,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 32,
          height: 32,
          child: Center(
            child: Icon(icon, size: 18, color: Colors.white), // ← 전달된 icon 사용
          ),
        ),
      ),
    );
  }
}
