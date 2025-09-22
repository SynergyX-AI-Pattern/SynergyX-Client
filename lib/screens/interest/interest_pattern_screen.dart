import 'package:flutter/material.dart';
import 'package:stockapp/data/backtest_api.dart';
import 'package:stockapp/data/interest_pattern_api.dart';
import 'package:stockapp/data/pattern_apply_api.dart';
import 'package:stockapp/models/pattern_apply.dart';
import 'package:stockapp/screens/interest/pattern_library_screen.dart';
import 'package:stockapp/widgets/common/app_confirm_dialog.dart';
import 'package:stockapp/widgets/interest/backtest_config_dialog.dart';
import 'package:stockapp/widgets/interest/pattern_empty_view.dart';
import 'package:stockapp/widgets/interest/pattern_exists_view.dart';
import 'package:stockapp/widgets/interest/pattern_stock_header.dart';

class InterestPatternScreen extends StatefulWidget {
  final int stockId;
  final String? stockName;
  final String? stockImageUrl;

  const InterestPatternScreen({super.key, required this.stockId, this.stockName, this.stockImageUrl,});

  @override
  State<InterestPatternScreen> createState() => _InterestPatternScreenState();
}

class _InterestPatternScreenState extends State<InterestPatternScreen> {
  final _api = PatternApi();
  late Future<PatternApply?> _future;
  final _applyApi = PatternApplyApi(); // delete 호출
  bool _runningBacktest = false;

  Future<void> _onRunBacktest(int patternId) async {
    // 1) 다이얼로그로 입력 받기
    final cfg = await showBacktestConfigDialog(context);
    if (cfg == null) return;

    setState(() => _runningBacktest = true);
    try {
      // 2) API 호출
      await BacktestService.run(
        patternId: patternId,
        stockId: widget.stockId,
        startDate: cfg.startDate,
        endDate: cfg.endDate,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('백테스팅이 실행되었습니다.')));

      // 3) 결과 새로고침
      await Future.delayed(const Duration(seconds: 1));

      try {
        await _reload(); // 결과 조회
      } catch (e) {
        debugPrint('새로고침 실패: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('결과가 아직 준비 중입니다. 잠시 후 다시 시도해주세요.')),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      // 실행 자체가 실패한 경우에만 이쪽으로 옴
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('백테스팅 실행 실패: $e')),
      );
    } finally {
      if (mounted) setState(() => _runningBacktest = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _future = _api.fetchPatternApply(widget.stockId);
  }

  Future<void> _reload() async {
    setState(() => _future = _api.fetchPatternApply(widget.stockId));
    await _future;
  }

  Future<void> _confirmAndDelete(int patternApplyId) async {
    final ok = await showAppConfirmDialog(
      context,
      title: "전략 패턴을 삭제하시겠습니까?",
      content: "이 동작은 취소할 수 없으며 내 전략 차트가 삭제됩니다.",
      cancelText: '취소',
      confirmText: '삭제'
    );
    if (ok != true) return;

    try {
      await _applyApi.delete(patternApplyId);

      if (!mounted) return;

      // ★ 1) 낙관적 갱신: 즉시 EmptyView로 전환
      setState(() {
        _future = Future<PatternApply?>.value(null);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('패턴이 해제되었습니다.')),
      );

      // ★ 2) 서버 상태 동기화: 약간의 지연 후 재조회(백엔드 반영 지연 대비)
      await Future.delayed(const Duration(milliseconds: 150));
      _reload();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('패턴 해제 실패: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PatternApply?>( // 그대로 OK
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snap.hasError) {
          return Scaffold(
            appBar: AppBar(title: Text(widget.stockName ?? '패턴')),
            body: Center(
              child: TextButton.icon(
                onPressed: _reload,
                icon: const Icon(Icons.refresh),
                label: Text('불러오기 실패: ${snap.error}'),
              ),
            ),
          );
        }

        final data = snap.data; // null = 패턴 없음
        final title = data != null && data.stockName.isNotEmpty
            ? data.stockName
            : (widget.stockName ?? '패턴');
        final hasPattern = data != null && data.hasPattern;
        final headerImg = (data?.stockImage.isNotEmpty ?? false)
            ? data!.stockImage
            : widget.stockImageUrl;

        return Scaffold(
          appBar: AppBar(backgroundColor: Colors.white),
          backgroundColor: Colors.white,
          body: RefreshIndicator(
            onRefresh: _reload,
            child: Column(
              children: [
                StockHeader(name: title, imageUrl: headerImg),
                Expanded(
                  child: hasPattern
                      ? PatternExistsView(
                    data: data!,
                    onDelete: () {
                      final id = data.patternApplyId;
                      if (id == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('패턴 식별자를 찾을 수 없습니다.')),
                        );
                        return;
                      }
                      _confirmAndDelete(id);
                    },
                    onEdit: () {final id = data.patternApplyId; // PatternApply 모델의 id
                    if (id == null) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PatternLibraryScreen(
                          stockId: widget.stockId,
                          stockName: widget.stockName,
                          patternApplyId: id, // ← 여기!
                        ),
                      ),
                    );},
                    onRunBacktest: _runningBacktest
                        ? null
                        : () => _onRunBacktest(data.pattern!.patternId),
                  )
                      : PatternEmptyView(
                    onAdd: () async {
                      final applied = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PatternLibraryScreen(
                            stockId: widget.stockId,
                            stockName: title,
                          ),
                        ),
                      );

                      if (applied == true) {
                        // 즉시 '있음' 화면으로 전환 후 서버 동기화
                        setState(() => _future = Future.value(null));
                        await Future.delayed(const Duration(milliseconds: 120));
                        _reload();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
