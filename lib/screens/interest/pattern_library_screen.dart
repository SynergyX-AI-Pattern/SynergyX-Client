import 'package:flutter/material.dart';
import 'package:stockapp/data/pattern_api.dart';
import 'package:stockapp/data/pattern_apply_api.dart';
import 'package:stockapp/models/pattern.dart';
import 'package:stockapp/screens/interest/interest_pattern_screen.dart';
import 'package:stockapp/widgets/interest/pattern_no_pattern_view.dart';
import 'package:stockapp/widgets/interest/pattern_pick_card.dart';

class PatternLibraryScreen extends StatefulWidget {
  final int stockId;
  final String? stockName;
  const PatternLibraryScreen({super.key, required this.stockId, this.stockName});

  @override
  State<PatternLibraryScreen> createState() => _PatternLibraryScreenState();
}

class _PatternLibraryScreenState extends State<PatternLibraryScreen> {
  final _applyApi = PatternApplyApi();
  bool _applying = false;
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
    if (_applying) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('‘${p.patternName}’ 적용할까요?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('취소')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('적용')),
        ],
      ),
    );
    if (ok == true) await _apply(p);
  }

  Future<void> _apply(Pattern p) async {
    setState(() => _applying = true);
    try {
      await _applyApi.applySimple(
        patternId: p.patternId,
        stockId: widget.stockId,
        entryAt: DateTime.now(),
        minValidReturn: 0,
      );
      if (!mounted) return;

      // 스택 재구성: 라이브러리 → 이전 패턴 화면 pop → 관심 화면으로 돌아간 뒤 새 패턴 화면 push
      Navigator.of(context).pop(); // C
      Navigator.of(context).pop(); // B → A
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
        SnackBar(content: Text('적용 실패: $e')),
      );
    } finally {
      if (mounted) setState(() => _applying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.stockName ?? '전략 패턴'),
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
            return const PatternNoPatternView(); // ← 분리된 위젯
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final p = items[i];
              return PatternPickCard(             // ← 분리된 위젯
                pattern: p,
                applying: _applying,
                onApply: _applying ? null : () => _onApplyPressed(p),
              );
            },
          );
        },
      ),
    );
  }
}
