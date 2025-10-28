import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stockapp/models/backtest_ranking.dart';
import 'package:stockapp/services/backtest_ranking_service.dart';

/// 백테스트 랭킹 전체 화면 (디자인 개편)
class BacktestRankingScreen extends StatefulWidget {
  const BacktestRankingScreen({super.key});

  @override
  State<BacktestRankingScreen> createState() => _BacktestRankingScreenState();
}

class _BacktestRankingScreenState extends State<BacktestRankingScreen> {
  final BacktestRankingService _service = BacktestRankingService();
  late Future<List<BacktestRanking>> _rankingFuture;

  final NumberFormat _percentFormat = NumberFormat('##0.0'); // 승률 82.3%
  final NumberFormat _returnFormat = NumberFormat('##0.00'); // 수익률 +12.34%

  @override
  void initState() {
    super.initState();
    _rankingFuture = _service.fetchRankings();
  }

  Future<void> _refreshRankings() async {
    setState(() {
      _rankingFuture = _service.fetchRankings();
    });
    await _rankingFuture;
  }

  String _formatWinRate(double value) => '${_percentFormat.format(value)}%';

  /// +, - 기호가 포함된 수익률 포맷
  String _formatSignedReturn(double value) {
    final sign = value >= 0 ? '+' : '';
    return '$sign${_returnFormat.format(value)}%';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshRankings,
          child: FutureBuilder<List<BacktestRanking>>(
            future: _rankingFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    SizedBox(height: 220),
                    Center(child: CircularProgressIndicator()),
                  ],
                );
              }

              if (snapshot.hasError) {
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: Colors.redAccent),
                    const SizedBox(height: 16),
                    const Text(
                      '랭킹 정보를 불러오지 못했습니다.',
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${snapshot.error}',
                      style:
                      TextStyle(color: theme.textTheme.bodySmall?.color),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _refreshRankings,
                      child: const Text('다시 시도'),
                    ),
                  ],
                );
              }

              final rankings = snapshot.data ?? const <BacktestRanking>[];
              if (rankings.isEmpty) {
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                  children: const [
                    Icon(Icons.emoji_events_outlined,
                        size: 48, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      '표시할 랭킹 정보가 없습니다.',
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      '백테스트를 실행해 랭킹에 도전해 보세요!',
                      textAlign: TextAlign.center,
                    ),
                  ],
                );
              }

              final topThree =
              rankings.length > 3 ? rankings.sublist(0, 3) : rankings;
              final others = rankings.length > 3
                  ? rankings.sublist(3)
                  : <BacktestRanking>[];

              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      SizedBox(height: 12),
                      Text(
                        '🏆 10월의 백테스팅 랭킹 🏆',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        '(최대 수익률 기준)',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF9CA3AF),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 24),
                    ],
                  ),
                  // 상위 1~3위 타일
                  ...topThree.map((r) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _TopRankTile(
                      ranking: r,
                      winRateText: _formatWinRate(r.winRate),
                      avgReturnText:
                      _formatSignedReturn(r.averageReturn),
                      maxReturnText: _formatSignedReturn(r.maxReturn),
                    ),
                  )),

                  if (others.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    const Divider(height: 32),
                    // 나머지 순위: 닉네임과 최대 수익률만
                    ...others.map((r) => Padding(
                      padding:
                      const EdgeInsets.symmetric(vertical: 16),
                      child: _SimpleRankRow(
                        rank: r.rank,
                        username: r.username,
                        maxReturnText:
                        _formatSignedReturn(r.maxReturn),
                      ),
                    )),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// 1~3위 전용 타일: 메달/왕관 + 닉네임 + 지표 카드
class _TopRankTile extends StatelessWidget {
  const _TopRankTile({
    required this.ranking,
    required this.winRateText,
    required this.avgReturnText,
    required this.maxReturnText,
  });

  final BacktestRanking ranking;
  final String winRateText;
  final String avgReturnText;
  final String maxReturnText;

  @override
  Widget build(BuildContext context) {
    final medalType = _medalForRank(ranking.rank);
    final accent = _accentForRank(ranking.rank);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _MedalIcon(medal: medalType, color: accent),
              const SizedBox(width: 8),
              Text(
                '${ranking.rank}위 ${ranking.username}',
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFF),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                _MetricColumn(label: '승률', value: winRateText),
                _MetricColumn(
                    label: '평균 수익률',
                    value: avgReturnText,
                    highlight: true),
                _MetricColumn(
                  label: '최대 수익률',
                  value: maxReturnText,
                  subText: ranking.formattedMaxReturnDate,
                  highlight: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _Medal _medalForRank(int r) {
    switch (r) {
      case 1:
        return _Medal.crown;
      case 2:
        return _Medal.silver;
      default:
        return _Medal.bronze;
    }
  }

  Color _accentForRank(int r) {
    switch (r) {
      case 1:
        return const Color(0xFFFFC107);
      case 2:
        return const Color(0xFF9CA3AF);
      default:
        return const Color(0xFFCD7F32);
    }
  }
}

enum _Medal { crown, silver, bronze }

class _MedalIcon extends StatelessWidget {
  const _MedalIcon({required this.medal, required this.color});
  final _Medal medal;
  final Color color;

  @override
  Widget build(BuildContext context) {
    IconData data;
    switch (medal) {
      case _Medal.crown:
        data = Icons.military_tech; // 왕관 느낌의 트로피 아이콘
        break;
      case _Medal.silver:
        data = Icons.military_tech; // 메달 모양
        break;
      case _Medal.bronze:
        data = Icons.military_tech;
        break;
    }
    return Icon(data, color: color, size: 28);
  }
}

class _MetricColumn extends StatelessWidget {
  const _MetricColumn({
    required this.label,
    required this.value,
    this.subText,
    this.highlight = false,
  });

  final String label;
  final String value;
  final String? subText;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final valueStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w800,
      color: highlight
          ? const Color(0xFF2563EB)
          : const Color(0xFF111827),
    );

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 12, color: Color(0xFF6B7280))),
          const SizedBox(height: 6),
          Text(value, style: valueStyle),
          if (subText != null) ...[
            const SizedBox(height: 4),
            Text(
              subText!,
              style: const TextStyle(
                  fontSize: 11, color: Color(0xFF6B7280)),
            ),
          ],
        ],
      ),
    );
  }
}

/// 4위 이하 단순 행: "N위 닉네임" + 오른쪽 "최대 수익률 +x.xx%"
class _SimpleRankRow extends StatelessWidget {
  const _SimpleRankRow({
    required this.rank,
    required this.username,
    required this.maxReturnText,
  });

  final int rank;
  final String username;
  final String maxReturnText;

  @override
  Widget build(BuildContext context) {
    final bool isTopFive = rank <= 5;

    return Row(
      children: [
        Expanded(
          child: Text(
            '${rank}위 $username',
            style:
            const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
        Text(
          '최대 수익률 ',
          style: TextStyle(
            fontSize: 13,
            color:
            isTopFive ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
          ),
        ),
        Text(
          maxReturnText,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: Color(0xFF2563EB),
          ),
        ),
      ],
    );
  }
}
