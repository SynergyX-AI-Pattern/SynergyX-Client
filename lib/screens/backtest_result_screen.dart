import 'package:flutter/material.dart';
import 'package:interactive_chart/interactive_chart.dart';
import 'package:stockapp/data/candle_api.dart';

class BacktestResultScreen extends StatefulWidget {
  final Map<String, dynamic> result; // 하위호환: 루트/중첩 어디든 올 수 있음

  const BacktestResultScreen({super.key, required this.result});

  @override
  State<BacktestResultScreen> createState() => _BacktestResultScreenState();
}

class _BacktestResultScreenState extends State<BacktestResultScreen> {
  List<CandleData> _candles = [];
  bool _candleLoading = false;

  // ---------- 유틸: 응답 정규화 ----------
  // 표준 {result:{...}} 이면 언래핑, 아니면 루트를 그대로 사용
  Map<String, dynamic> get _res {
    final root = widget.result;
    final r = root['result'];
    return (r is Map) ? Map<String, dynamic>.from(r) : root; // 변경: 불필요 캐스트 제거
  }

  T? _asNum<T extends num>(dynamic v) {
    if (v is T) return v;
    if (v is num) return (T == int) ? v.toInt() as T : v.toDouble() as T;
    if (v is String) {
      final n = num.tryParse(v);
      if (n == null) return null;
      return (T == int) ? n.toInt() as T : n.toDouble() as T;
    }
    return null;
  }

  String _fmtPercent(dynamic v, {int fraction = 2}) {
    final n = _asNum<double>(v) ?? 0.0;
    // 서버가 0.12(=12%)인지 12(=12%)인지 모호할 수 있어 화면에서는 값 그대로 % 처리
    return '${n.toStringAsFixed(fraction)}%';
  }

  // 변경: YYYY-MM-DD만 보이도록 간단 포매터 추가
  String _fmtDate(String? s) {
    if (s == null || s.isEmpty) return '-';
    return s.split('T').first; // ISO 형태면 'T' 앞부분만 사용
  }

  @override
  void initState() {
    super.initState();
    _loadCandles();
  }

  Future<void> _loadCandles() async {
    final res = _res;

    // 여러 경로에서 stockId를 탐색 (호출부에서 루트에 주입했을 수도 있음)
    final dynamic stockIdDyn =
        res['stockId'] ?? widget.result['stockId'] ?? (res['stock'] is Map ? (res['stock'] as Map)['id'] : null);
    final String? stockId =
    (stockIdDyn == null) ? null : stockIdDyn.toString();

    if (stockId == null) {
      debugPrint('⚠️ stockId가 없어 캔들 요청을 생략합니다.');
      return;
    }

    setState(() => _candleLoading = true);
    try {
      // ✅ API 연동: 1D 고정 (필요 시 응답/설정에서 추출)
      final candles = await fetchCandles(stockId: stockId, interval: '1D');
      setState(() {
        _candles = candles;
        _candleLoading = false;
      });
    } catch (e) {
      debugPrint('⚠️ 캔들 로딩 실패: $e');
      setState(() {
        _candleLoading = false;
        _candles = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final res = _res; // 정규화된 결과
    final stockName = (res['stockName'] ?? widget.result['stockName'] ?? '-').toString();

    // 변경: 시작/종료일 둘 다 변수로 받아 UI에서 "기간: 시작 ~ 종료" 표기
    final String? startDate = res['startDate']?.toString() ?? widget.result['startDate']?.toString();
    final String? endDate   = res['endDate']?.toString()   ?? widget.result['endDate']?.toString();

    // 사용자 입력(목표 수익률) 전달값
    final double? target = _asNum<double>(widget.result['targetReturn']);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('백테스팅 결과', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0, // 변경: 상단 그림자 제거 (이미지 디자인 맞춤)
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 변경: 상단 실행일/매칭횟수 요약
            Row(
              children: [
                Text('실행일: ${res["executedAt"] ?? "-"}',
                    style: const TextStyle(color: Colors.grey)),
                const Spacer(),
                Text('매칭 횟수: ${res["matchedCount"] ?? "-"}',
                    style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 12),

            // 변경: 종목 로고 + 종목명
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(res["stockImage"] ?? ""),
                  backgroundColor: Colors.grey.shade200,
                ),
                const SizedBox(width: 12),
                Text(
                  stockName,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 차트 카드 영역
            SizedBox(
              height: 200,
              child: _candleLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _candles.isEmpty
                  ? const Center(child: Text('캔들 데이터 없음'))
                  : InteractiveChart(
                candles: _candles,
                style: const ChartStyle(
                  priceGainColor: Color(0xFFDF1525),
                  priceLossColor: Color(0xFF1573FE),
                  // 라벨 색상 등은 기본값 사용 (디자인에 맞게 최소화)
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 변경: "기간: 시작 ~ 종료" + "수익률" 한 줄 카드
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
              ),
              child: Row(
                children: [
                  Text('기간: ${_fmtDate(startDate)} ~ ${_fmtDate(endDate)}'), // 변경: 전체 기간 표기
                  const Spacer(),
                  if (target != null) Text('수익률: ${target.toStringAsFixed(2)}%'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 변경: 주요 통계 카드 (이미지처럼 2행 구성)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            const Text("승률", style: TextStyle(color: Colors.grey)),
                            const SizedBox(height: 4),
                            Text(_fmtPercent(res['winRate']),
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            const Text("평균 수익률", style: TextStyle(color: Colors.grey)),
                            const SizedBox(height: 4),
                            Text(_fmtPercent(res['averageReturn']),
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF289BF6))),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            const Text("최대 수익률", style: TextStyle(color: Colors.grey)),
                            const SizedBox(height: 4),
                            Text(_fmtPercent(res['maxReturn']),
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF289BF6))),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            const Text("최대 손실률", style: TextStyle(color: Colors.grey)),
                            const SizedBox(height: 4),
                            Text(_fmtPercent(res['maxLoss']),
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold, color: Colors.red)),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            const Text("누적 수익률", style: TextStyle(color: Colors.grey)),
                            const SizedBox(height: 4),
                            Text(_fmtPercent(res['cumulativeReturn']),
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF289BF6))),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            const Text("마지막 수익률", style: TextStyle(color: Colors.grey)),
                            const SizedBox(height: 4),
                            Text(_fmtPercent(res['lastReturn']),
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF289BF6))),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text("마지막 매칭일: ${res["lastMatchDate"] ?? "-"}",
                      style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
