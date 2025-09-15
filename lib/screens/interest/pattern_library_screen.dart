// lib/screens/interest/pattern_library_screen.dart
import 'package:flutter/material.dart';
import 'package:stockapp/data/pattern_api.dart';
import 'package:stockapp/data/pattern_apply_api.dart';
import 'package:stockapp/models/pattern.dart';
import 'package:stockapp/screens/interest/interest_pattern_screen.dart';
import 'package:stockapp/widgets/common/app_confirm_dialog.dart';
import 'package:stockapp/widgets/interest/pattern_no_pattern_view.dart';
import 'package:stockapp/widgets/interest/pattern_pick_card.dart';

class PatternLibraryScreen extends StatefulWidget {
  final int stockId;
  final String? stockName;

  /// 수정 플로우로 들어온 경우만 전달 (없으면 신규 적용 플로우)
  final int? patternApplyId;

  const PatternLibraryScreen({
    super.key,
    required this.stockId,
    this.stockName,
    this.patternApplyId,
  });

  @override
  State<PatternLibraryScreen> createState() => _PatternLibraryScreenState();
}

class _PatternLibraryScreenState extends State<PatternLibraryScreen> {
  final _applyApi = PatternApplyApi();
  bool _working = false; // ← _applying 대신
  late Future<List<Pattern>> _future;

  @override
  void initState() {
    super.initState();
    _future = PatternApi.getPatterns();
  }

  Future<void> _reload() async {
    setState(() => _future = PatternApi.getPatterns());
    await _future;
  }

  Future<void> _onApplyPressed(Pattern p) async {
    if (_working) return;
    final ok = await showAppConfirmDialog(
      context,
      title: "'${p.patternName}' 패턴을 ${widget.patternApplyId != null ? '수정' : '적용'}할까요?",
    );
    if (ok == true) {
      await _applyOrUpdate(p);
    }
  }

  // ★ 여기 넣으세요
  Future<void> _applyOrUpdate(Pattern p) async {
    setState(() => _working = true);
    try {
      if (widget.patternApplyId != null) {
        // 🔧 수정 = 기존 적용 삭제 후 새 패턴 적용
        await _applyApi.replacePattern(
          patternApplyId: widget.patternApplyId!,
          stockId: widget.stockId,
          newPatternId: p.patternId,
          entryAt: DateTime.now(),
          minValidReturn: 0,
        );
      } else {
        // 🆕 신규 적용
        await _applyApi.applySimple(
          patternId: p.patternId,
          stockId: widget.stockId,
          entryAt: DateTime.now(),
          minValidReturn: 0,
        );
      }

      if (!mounted) return;
      // C(라이브러리) pop → B(기존 패턴 화면) pop → D(새 패턴 화면) push
      Navigator.of(context).pop();
      Navigator.of(context).pop();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => InterestPatternScreen(
            stockId: widget.stockId,
            stockName: widget.stockName,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('패턴 ${widget.patternApplyId != null ? '수정' : '적용'} 실패: $e')),
      );
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // Text 파라미터 순서 수정: Text('문자열', style: ...)
        title: Text(widget.stockName ?? '전략 패턴',
            style: const TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Pattern>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: TextButton.icon(
                onPressed: _reload,
                icon: const Icon(Icons.refresh),
                label: Text('불러오기 실패: ${snap.error}'),
              ),
            );
          }

          final items = snap.data ?? const <Pattern>[];
          if (items.isEmpty) {
            return const PatternNoPatternView();
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final p = items[i];
              return PatternPickCard(
                pattern: p,
                applying: _working,
                onApply: _working ? null : () => _onApplyPressed(p),
              );
            },
          );
        },
      ),
    );
  }
}
