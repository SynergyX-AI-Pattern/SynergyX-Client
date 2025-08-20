// lib/screens/interest/interest_pattern_screen.dart
import 'package:flutter/material.dart';
import 'package:stockapp/data/interest_pattern_api.dart';
import 'package:stockapp/models/pattern_apply.dart';
import 'package:stockapp/widgets/interest/pattern_empty_view.dart';
import 'package:stockapp/widgets/interest/pattern_exists_view.dart';
import 'package:stockapp/widgets/interest/pattern_stock_header.dart';

class InterestPatternScreen extends StatefulWidget {
  final int stockId;
  final String? stockName;

  const InterestPatternScreen({super.key, required this.stockId, this.stockName});

  @override
  State<InterestPatternScreen> createState() => _InterestPatternScreenState();
}

class _InterestPatternScreenState extends State<InterestPatternScreen> {
  final _api = PatternApi();
  late Future<PatternApply?> _future;

  @override
  void initState() {
    super.initState();
    _future = _api.fetchPatternApply(widget.stockId);
  }

  Future<void> _reload() async {
    setState(() => _future = _api.fetchPatternApply(widget.stockId));
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PatternApply?>(
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
        final img = (data != null && data.stockImage.isNotEmpty) ? data.stockImage : null;
        final hasPattern = data != null && data.hasPattern;

        return Scaffold(
          appBar: AppBar(),
          backgroundColor: Colors.white,
          body: RefreshIndicator(
            onRefresh: _reload,
            child: Column(
              children: [
                StockHeader(name: title, imageUrl: img),
                Expanded(
                  child: hasPattern
                      ? PatternExistsView(
                    data: data!,
                    onDelete: () {/* TODO */},
                    onEdit: () {/* TODO */},
                    onRunBacktest: () {/* TODO */},
                  )
                      : const PatternEmptyView(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
