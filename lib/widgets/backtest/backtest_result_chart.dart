import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:interactive_chart/interactive_chart.dart';

import 'package:stockapp/data/backtest_api.dart';
import 'package:stockapp/data/backtest_candle_api.dart';
import 'package:stockapp/widgets/backtest/backtest_result_overlay.dart';

class BacktestHighlightChart extends StatefulWidget {
  final Map<String, dynamic> summary;
  final ChartStyle chartStyle;
  final String emptyMessage;
  final ValueChanged<Map<String, dynamic>>? onDetailLoaded;

  const BacktestHighlightChart({
    super.key,
    required this.summary,
    this.chartStyle = const ChartStyle(
      priceGainColor: Color(0xFFDF1525),
      priceLossColor: Color(0xFF1573FE),
    ),
    this.emptyMessage = '캔들 데이터 없음',
    this.onDetailLoaded,
  });

  @override
  State<BacktestHighlightChart> createState() => _BacktestHighlightChartState();
}

class _BacktestHighlightChartState extends State<BacktestHighlightChart> {
  Map<String, dynamic>? _detail;
  List<CandleData> _candles = const <CandleData>[];
  List<int> _patternPoints = const <int>[];
  int? _highlightStart;
  int? _highlightEnd;
  DateTime? _hlFrom;
  DateTime? _hlTo;
  bool _loading = false;
  String? _error;

  /// summary/result 구조가 제각각이어서 실제 result 맵을 통일된 형태로 반환한다.
  Map<String, dynamic> get _normalized {
    final root = _detail ?? widget.summary;
    final result = root['result'];
    if (result is Map) {
      return Map<String, dynamic>.from(result as Map);
    }
    return Map<String, dynamic>.from(root);
  }

  @override
  void initState() {
    super.initState();
    _applyBestMatch(_normalized);
    _loadDetailAndCandles();
  }

  @override
  void didUpdateWidget(covariant BacktestHighlightChart oldWidget) {
    super.didUpdateWidget(oldWidget);

    final int? oldId = _asInt(_extractBacktestId(oldWidget.summary));
    final int? newId = _asInt(_extractBacktestId(widget.summary));

    if (oldId != newId || !mapEquals(oldWidget.summary, widget.summary)) {
      setState(() {
        _detail = null;
      });
      _applyBestMatch(_normalize(widget.summary));
      _loadDetailAndCandles();
    }
  }

  /// summary 또는 detail 에서 backtestId 후보를 추출한다.
  dynamic _extractBacktestId(Map<String, dynamic> source) {
    final normalized = _normalize(source);
    return normalized['backtestId'] ?? source['backtestId'];
  }

  /// 다양한 형태의 숫자를 안전하게 int 로 변환한다.
  int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  /// 다양한 형태의 숫자를 안전하게 double 로 변환한다.
  double? _asDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  /// 문자열 또는 DateTime 값을 DateTime 으로 파싱한다.
  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    final String str = value.toString();
    if (str.isEmpty) return null;
    return DateTime.tryParse(str);
  }

  /// best match 정보로부터 하이라이트 범위와 패턴 포인트를 추출한다.
  void _applyBestMatch(Map<String, dynamic> data) {
    final dynamic hr = data['highlightRange'];
    final bool hasHighlightRange =
        hr is Map && hr['fromDate'] != null && hr['toDate'] != null;

    List<int> points = const <int>[];
    final dynamic matchesRaw = data['matches'] ?? data['matchResults'];
    if (matchesRaw is List && matchesRaw.isNotEmpty) {
      Map<String, dynamic> best = Map<String, dynamic>.from(matchesRaw.first as Map);
      double bestReturn =
          _asDouble(best['return'] ?? best['profit'] ?? best['returnRate'] ?? best['rate']) ??
              0;

      for (final match in matchesRaw.skip(1)) {
        if (match is! Map) continue;
        final double candidate = _asDouble(
          match['return'] ?? match['profit'] ?? match['returnRate'] ?? match['rate'],
        ) ??
            0;
        if (candidate > bestReturn) {
          bestReturn = candidate;
          best = Map<String, dynamic>.from(match as Map);
        }
      }

      final dynamic pattern = best['patternPoints'] ?? best['points'];
      if (pattern is List) {
        points = pattern.map((e) => _asInt(e) ?? 0).toList();
      }

      if (!hasHighlightRange) {
        final int? start =
        _asInt(best['startIndex'] ?? best['matchStartIndex'] ?? best['start']);
        final int? end =
        _asInt(best['endIndex'] ?? best['matchEndIndex'] ?? best['end']);
        setState(() {
          _patternPoints = points;
          _highlightStart = start;
          _highlightEnd = end;
          _hlFrom = null;
          _hlTo = null;
        });
        return;
      }
    }

    if (hasHighlightRange) {
      setState(() {
        _patternPoints = points;
        _highlightStart = null;
        _highlightEnd = null;
        _hlFrom = _parseDate(hr['fromDate']);
        _hlTo = _parseDate(hr['toDate']);
      });
      return;
    }

    final int? start =
    _asInt(data['startIndex'] ?? data['matchStartIndex'] ?? data['matchStart']);
    final int? end =
    _asInt(data['endIndex'] ?? data['matchEndIndex'] ?? data['matchEnd']);
    setState(() {
      _patternPoints = points;
      _highlightStart = start;
      _highlightEnd = end;
      _hlFrom = null;
      _hlTo = null;
    });
  }

  /// highlightRange 가 날짜로만 주어졌을 때 캔들 인덱스로 보정한다.
  void _applyHighlightFromDates() {
    if (_hlFrom == null || _hlTo == null || _candles.isEmpty) return;

    final DateTime from = _hlFrom!.toLocal();
    final DateTime to = _hlTo!.toLocal();

    int? startIdx;
    for (int i = 0; i < _candles.length; i++) {
      final DateTime ts =
      DateTime.fromMillisecondsSinceEpoch(_candles[i].timestamp).toLocal();
      if (!ts.isBefore(from)) {
        startIdx = i;
        break;
      }
    }
    if (startIdx == null) return;

    int endIdx = _candles.length - 1;
    for (int i = startIdx; i < _candles.length; i++) {
      final DateTime ts =
      DateTime.fromMillisecondsSinceEpoch(_candles[i].timestamp).toLocal();
      if (ts.isAfter(to)) {
        endIdx = i - 1;
        break;
      }
    }
    if (endIdx < startIdx) return;

    setState(() {
      _highlightStart = startIdx;
      _highlightEnd = endIdx;
    });
  }

  /// 현재 보유한 캔들 길이에 맞춰 하이라이트 범위를 보정한다.
  void _clampHighlightToCandles() {
    if (_candles.isEmpty || _highlightStart == null || _highlightEnd == null) {
      return;
    }

    int start = _highlightStart!.clamp(0, _candles.length - 1);
    int end = _highlightEnd!.clamp(0, _candles.length - 1);
    if (end < start) {
      end = start;
    }

    if (start != _highlightStart || end != _highlightEnd) {
      setState(() {
        _highlightStart = start;
        _highlightEnd = end;
      });
    }
  }

  /// 백테스트 상세와 캔들을 순차적으로 로드한다.
  Future<void> _loadDetailAndCandles() async {
    final Map<String, dynamic> normalized = _normalized;
    final int? backtestId =
    _asInt(normalized['backtestId'] ?? widget.summary['backtestId']);

    if (backtestId == null) {
      setState(() {
        _candles = const <CandleData>[];
        _highlightStart = null;
        _highlightEnd = null;
        _patternPoints = const <int>[];
        _error = 'backtestId가 없어 차트를 표시할 수 없습니다.';
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _candles = const <CandleData>[];
    });

    try {
      Map<String, dynamic>? detail;
      try {
        detail = await BacktestService.fetchBacktestResult(
          backtestId,
          stockId: _asInt(widget.summary['stockId'] ?? normalized['stockId']),
        );
      } catch (e, st) {
        debugPrint('⚠️ 백테스트 상세 로딩 실패: $e\n$st');
      }

      if (!mounted) return;

      if (detail != null) {
        setState(() {
          _detail = detail;
        });
        widget.onDetailLoaded?.call(detail);
        _applyBestMatch(_normalize(detail));
      } else {
        setState(() {
          _detail = null;
        });
        _applyBestMatch(_normalize(widget.summary));
      }

      final List<CandleData> candles = await fetchBacktestCandles(backtestId: backtestId);
      if (!mounted) return;
      setState(() {
        _candles = candles;
        _loading = false;
      });
      _applyHighlightFromDates();
      _clampHighlightToCandles();
    } catch (e, st) {
      if (!mounted) return;
      debugPrint('❌ 백테스트 캔들 로딩 실패: $e\n$st');
      setState(() {
        _candles = const <CandleData>[];
        _highlightStart = null;
        _highlightEnd = null;
        _patternPoints = const <int>[];
        _loading = false;
        _error = '캔들 데이터를 불러오지 못했습니다.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text(_error!, style: const TextStyle(color: Colors.grey)));
    }
    if (_candles.isEmpty) {
      return Center(child: Text(widget.emptyMessage));
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        InteractiveChart(
          candles: _candles,
          style: widget.chartStyle,
        ),
        if (_highlightStart != null &&
            _highlightEnd != null &&
            _highlightEnd! >= _highlightStart!)
          Positioned.fill(
            child: CustomPaint(
              painter: BacktestMatchOverlayPainter(
                start: _highlightStart!,
                end: _highlightEnd!,
                total: _candles.length,
                patternPoints: _patternPoints,
              ),
            ),
          ),
      ],
    );
  }
}

/// detail/result 구성을 정규화하는 헬퍼.
Map<String, dynamic> _normalize(Map<String, dynamic> raw) {
  final result = raw['result'];
  if (result is Map) {
    return Map<String, dynamic>.from(result as Map);
  }
  return Map<String, dynamic>.from(raw);
}