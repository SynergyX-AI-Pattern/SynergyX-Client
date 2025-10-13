import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:interactive_chart/interactive_chart.dart';
import 'dart:math' as math;
import 'dart:ui';

import 'package:stockapp/models/pattern.dart';
import 'package:stockapp/screens/search_info_screen.dart';
import 'package:stockapp/screens/backtest/backtest_result_screen.dart';
import 'package:stockapp/screens/backtest/backtest_list_screen.dart';

import 'chart_edit_screen.dart';
import '../../data/candle_api.dart';
import '../../data/pattern_api.dart';
import '../../data/backtest_api.dart';

import '../../widgets/backtest/backtest_pop.dart';
import '../../widgets/backtest/recent_backtest_result_card.dart';

import 'package:stockapp/models/StockItemModel.dart';
import 'package:stockapp/screens/stock_detail_screen.dart';

class PatternDetailPage extends StatefulWidget {
  final int patternId;

  const PatternDetailPage({super.key, required this.patternId});


  factory PatternDetailPage.fromPattern(Pattern pattern, {Key? key}) {
    return PatternDetailPage(key: key, patternId: pattern.patternId);
  }

  @override
  State<PatternDetailPage> createState() => _PatternDetailPageState();
}

class _PatternDetailPageState extends State<PatternDetailPage> {
  PatternDetail? _pattern;
  bool _isLoading = true;
  bool _edited = false;

  late final TextEditingController _titleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchPatternDetail();
  }

  Future<void> _fetchPatternDetail() async {
    try {
      final detail = await PatternApi.getPatternDetail(widget.patternId); // API 호출
      if (!mounted) return;
      setState(() {
        _pattern = detail; // [정리] as 캐스팅 불필요
        _titleController.text = detail.patternName;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("❌ 패턴 상세 불러오기 실패: $e");
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _runBacktestForStock(int stockId, String symbol) async {
    if (_pattern == null) return;

    // 기존 백테스트의 시작일이 있으면 재사용, 없으면 1년 전으로 기본값 설정
    final startStr = _pattern!.backtestResult?['startDate']?.toString();
    final startDate = startStr != null
        ? DateTime.tryParse(startStr) ?? DateTime.now().subtract(const Duration(days: 365))
        : DateTime.now().subtract(const Duration(days: 365));

    try {
      final raw = await BacktestService.run(
        patternId: _pattern!.patternId,
        stockId: stockId,
        startDate: startDate,
        endDate: DateTime.now(),
      );

      // API 응답에서 result 래퍼가 있으면 벗겨낸다
      final normalized = raw['result'] is Map
          ? Map<String, dynamic>.from(raw['result'])
          : Map<String, dynamic>.from(raw);

      // 새로운 백테스트 결과로 상태 갱신
      setState(() {
        _pattern = PatternDetail(
          patternId: _pattern!.patternId,
          patternName: _pattern!.patternName,
          points: _pattern!.points,
          tolerance: _pattern!.tolerance,
          periodValue: _pattern!.periodValue,
          periodUnit: _pattern!.periodUnit,
          appliedStockList: _pattern!.appliedStockList,
          backtestResult: normalized,
        );
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('백테스트 실행 실패: $e')),
      );
    }
  }

  PatternRequest _buildRequestFromDetail(PatternDetail d) {
    return PatternRequest(
      patternId: d.patternId,
      patternName: d.patternName,
      points: d.points,
      tolerance: d.tolerance,
      periodValue: d.periodValue,
      periodUnit: d.periodUnit,
    );
  }

  Future<void> _saveTitle(String title) async {
    if (_pattern == null) return;
    final updated = PatternDetail(
      patternId: _pattern!.patternId,
      patternName: title,
      points: _pattern!.points,
      tolerance: _pattern!.tolerance,
      periodValue: _pattern!.periodValue,
      periodUnit: _pattern!.periodUnit,
      appliedStockList: _pattern!.appliedStockList,
      backtestResult: _pattern!.backtestResult,
    );
    try {
      await PatternApi.updatePattern(updated.patternId, _buildRequestFromDetail(updated));
      if (!mounted) return;
      setState(() {
        _pattern = updated;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ 제목이 저장되었습니다.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ 제목 저장 실패: $e')));
    }
  }

  Future<void> _applyStockBySymbol(String symbol, {int? stockId}) async {
    if (_pattern == null) return;

    final current = List<Map<String, dynamic>>.from(_pattern!.appliedStockList);
    final already = current.any((e) => (e['symbol'] ?? e['stockName'] ?? e['name']) == symbol);


    if (!already) {
      current.add({
        'symbol': symbol,
        'stockName': symbol,
        'stockId': stockId,
      });
    }

    final updated = PatternDetail(
      patternId: _pattern!.patternId,
      patternName: _pattern!.patternName,
      points: _pattern!.points,
      tolerance: _pattern!.tolerance,
      periodValue: _pattern!.periodValue,
      periodUnit: _pattern!.periodUnit,
      appliedStockList: current,
      backtestResult: _pattern!.backtestResult,
    );
    try {
      await PatternApi.updatePattern(updated.patternId, _buildRequestFromDetail(updated));
      if (!mounted) return;
      setState(() { _pattern = updated; });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ 종목이 적용되었습니다.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ 종목 적용 실패: $e')));
    }
  }

  Future<void> _removeAppliedStockAt(int index) async {
    if (_pattern == null) return;
    final current = List<Map<String, dynamic>>.from(_pattern!.appliedStockList);
    if (index < 0 || index >= current.length) return;
    current.removeAt(index);
    final updated = PatternDetail(
      patternId: _pattern!.patternId,
      patternName: _pattern!.patternName,
      points: _pattern!.points,
      tolerance: _pattern!.tolerance,
      periodValue: _pattern!.periodValue,
      periodUnit: _pattern!.periodUnit,
      appliedStockList: current,
      backtestResult: _pattern!.backtestResult,
    );
    try {
      await PatternApi.updatePattern(updated.patternId, _buildRequestFromDetail(updated));
      if (!mounted) return;
      setState(() { _pattern = updated; });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ 종목 삭제 실패: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_pattern == null) {
      return const Scaffold(
        body: Center(child: Text("❌ 패턴 데이터를 불러올 수 없습니다.")),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context, _edited),
        ),

        title: TextField(
          controller: _titleController,
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: '패턴 이름 입력',
          ),
          style: const TextStyle(color: Colors.black, fontSize: 18),
          onSubmitted: _saveTitle,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: Colors.black),
            onPressed: () => _saveTitle(_titleController.text),
          ),
          IconButton(
            icon: const Icon(Icons.play_arrow, color: Colors.black),
            tooltip: '백테스트 실행',
            onPressed: () {
              openBacktestPopup(context, _pattern!.toJson()); // ← 여기로 교체
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _pattern!.patternName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildPatternCard(context),
            const SizedBox(height: 20),
            Divider(color: const Color(0xFFD0CECE), thickness: 1),
            const SizedBox(height: 20),
            _buildBacktestCard(),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  final backtestId = _pattern!.backtestResult?['backtestId'] as int?;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BacktestListScreen(
                        patternId: _pattern!.patternId,
                        backtestId: backtestId,
                      ),
                    ),
                  );
                },
                style: TextButton.styleFrom(foregroundColor: Colors.black),
                child: const Text('전체 백테스팅 보기'),
              ),
            ),

            const SizedBox(height: 20),
            Divider(color: const Color(0xFFD0CECE), thickness: 1),
            const SizedBox(height: 20),
            _buildAppliedStocks(),
          ],
        ),
      ),
    );
  }

  /// 내 전략 패턴 카드
  Widget _buildPatternCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0x4DD9D9D9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 그래프 (흰색 칸)
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              height: 200,
              child: _buildPatternChart(_pattern!.points),
            ),
          ),

          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.start,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _buildTag("기간: ${_pattern!.periodValue} ${_pattern!.periodUnit}"),
              _buildTag("허용 오차: ${_pattern!.tolerance.toStringAsFixed(1)}"),
            ],
          ),

          const SizedBox(height: 12),

          // 버튼
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            OutlinedButton(
              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => Theme(
                    data: Theme.of(ctx).copyWith(
                      dialogTheme: const DialogThemeData(
                        backgroundColor: Colors.white,
                        surfaceTintColor: Colors.transparent,
                      ),
                    ),
                    child: AlertDialog(
                      title: const Text('전략 패턴을 삭제하시겠습니까?'),
                      content: const Text('이 동작은 취소할 수 없으며 내 전략 차트가 삭제됩니다.'),
                      actions: [
                        TextButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                          ),
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('취소'),
                        ),
                        FilledButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('삭제'),
                        ),
                      ],
                    ),
                  ),
                );


                if (ok != true) return;

                try {
                  await PatternApi.deletePattern(widget.patternId);
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✅ 패턴이 삭제되었습니다.')),
                  );
                  Navigator.pop(context, true);
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('❌ 삭제 실패: $e')),
                  );
                }
              },
              style: OutlinedButton.styleFrom(foregroundColor: Colors.black),
              child: const Text("삭제"),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () async {
                final updated = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChartEditPage(
                      patternData: _pattern!.toJson(),
                      onSaved: () async {
                        await _fetchPatternDetail();
                        return _pattern!.toJson();
                      },
                    ),
                  )
              );

              const SizedBox(height: 16);

                if (updated != null) {
                  setState(() => _pattern = PatternDetail.fromJson(updated));
                  _edited = true;
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              child: const Text("패턴 수정"),
            ),
          ]),
        ],
      ),
    );
  }

  /// 공통 카드 스타일
  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: const [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 4,
          offset: Offset(0, 2),
        ),
      ],
    );
  }

  //// 최근 백테스팅 결과 카드
  Widget _buildBacktestCard() {
    final backtest = _pattern!.backtestResult;
    if (backtest == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: _cardDecoration(),
        child: const Text("백테스트 결과 없음", style: TextStyle(color: Colors.grey)),
      );
    }

    // 최근 백테스트 카드는 내부에서 캔들과 하이라이트를 모두 불러온다.
    return RecentBacktestResultCard(
      backtest: backtest,
      onChangeStock: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const StockSearchPage()),
        );
        if (result is Map<String, dynamic> && result['id'] is int) {
          await _runBacktestForStock(result['id'] as int, result['symbol']);
        }
      }, // 종목 바꾸기 처리
      onTapDetail: () async {
        final id = backtest['backtestId'];
        Map<String, dynamic> detail = backtest;
        if (id != null) {
          detail = await BacktestService.fetchBacktestResult(
            id as int,
            stockId: backtest['stockId'],
          );
        }
        if (!context.mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BacktestResultScreen(result: detail),
          ),
        );
      }, // 상세 결과 화면 이동
      onRunBacktest: () {
        openBacktestPopup(context, _pattern!.toJson());
      }, // 다시 테스트 실행
    );
  }

  /// 패턴 적용 종목 카드 (흰색 배경)
  Widget _buildAppliedStocks() {
    final stocks = _pattern!.appliedStockList;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("패턴 적용한 종목",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          if (stocks.isEmpty)
            const Text("적용된 종목 없음", style: TextStyle(color: Colors.grey))
          else
            Column(
              children: [
                for (int i = 0; i < stocks.length; i++) ...[
                  InkWell(
                    onTap: () {
                      final dynamic id = stocks[i]['stockId'];
                      if (id == null) return; // ID 없으면 이동 중지
                      final int parsedId =
                      id is int ? id : int.tryParse(id.toString()) ?? 0;
                      final stockItem = StockItem(
                        rank: 0,
                        stockId: parsedId,
                        name: stocks[i]["stockName"] ?? '',
                        price: 0,
                        changeRate: 0,
                        imageUrl: stocks[i]["stockImage"] ?? '',
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => DetailScreen(stock: stockItem)),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 12),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F7F7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: _buildStockImage(stocks[i]["stockImage"] as String?),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  stocks[i]["stockName"] ??
                                      stocks[i]['name']?.toString() ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  stocks[i]["symbol"] ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () => _removeAppliedStockAt(i),
                          ),
                        ],
                      ),
                    ),
                  ),
                ]
              ],
            ),

          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const StockSearchPage(),
                  ),
                );
                if (result is Map<String, dynamic> && result['symbol'] is String) {

                  await _applyStockBySymbol(
                    result['symbol'],
                    stockId: result['id'] is int
                        ? result['id']
                        : int.tryParse(result['id']?.toString() ?? ''),
                  );  
                }

              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black,
                side: const BorderSide(color: Colors.black12),
              ),
              child: const Text('종목 추가'),
            ),
          ),
        ],
      ),
    );
  }

  /// 이미지 URL이 없을 때 기본 아이콘을 표시하는 위젯
  Widget _buildStockImage(String? url) {
    if (url != null && url.isNotEmpty) {
      return Image.network(
        url,
        width: 40,
        height: 40,
        fit: BoxFit.cover,
      );
    }
    return Container(
      width: 40,
      height: 40,
      color: Colors.grey[300],
      child: const Icon(Icons.image_not_supported,
          size: 24, color: Colors.grey),
    );
  }

  /// 태그 위젯
  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12)),
    );
  }

  /// 패턴 그래프 (직선 + 자동 격자)
  Widget _buildPatternChart(List<int> points) {
    if (points.isEmpty) return const SizedBox.shrink();

    final double maxY = points.reduce(math.max).toDouble();
    final spots = <FlSpot>[
      for (int i = 0; i < points.length; i++)
        FlSpot(i.toDouble(), (maxY - points[i]).toDouble()),
    ];

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (points.length - 1).toDouble(),
        minY: 0,
        maxY: maxY,
        titlesData: FlTitlesData(show: false),
        gridData: FlGridData(
          show: true,
          drawHorizontalLine: true,
          drawVerticalLine: true,
          horizontalInterval: (maxY / 5).ceilToDouble(),
          verticalInterval: (points.length / 6).ceilToDouble(),
          getDrawingHorizontalLine: (value) => const FlLine(
            color: Color(0xFFD0CECE), 
            strokeWidth: 1,
          ),
          getDrawingVerticalLine: (value) => const FlLine(
            color: Color(0xFFD0CECE),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: false,
            color: Colors.amber,
            barWidth: 2,
            dotData: FlDotData(show: true),
          ),
        ],
      ),
    );
  }
}

void openBacktestPopup(BuildContext context, Map<String, dynamic> patternData) {
  showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.transparent,
    builder: (_) {
      return Stack(
        children: [
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(color: Colors.white.withValues(alpha: 0.6)),
            ),
          ),
          Center(child: BacktestPopup(patternData: patternData)),
        ],
      );
    },
  );
}

