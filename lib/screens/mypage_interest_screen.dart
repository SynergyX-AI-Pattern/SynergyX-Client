import 'package:flutter/material.dart';
import 'package:stockapp/data/interestlist_api.dart';
import 'package:stockapp/data/watchlist_api.dart';
import 'package:stockapp/models/stock_brief.dart';
import 'package:stockapp/widgets/mypage/interest/empty_state.dart';
import 'package:stockapp/widgets/mypage/interest/stock_tile.dart';
import 'package:stockapp/services/list_refresh_notifiers.dart';

class WatchlistEditPage extends StatefulWidget {
  const WatchlistEditPage({super.key});

  @override
  State<WatchlistEditPage> createState() => _WatchlistEditPageState();
}

class _WatchlistEditPageState extends State<WatchlistEditPage> {
  bool _editMode = false;
  final Set<int> _selected = {}; // id는 int이므로 Set<int>
  final InterestlistApi _apiService = InterestlistApi();
  final WatchlistApiService _apiService2 = WatchlistApiService();

  List<StockBrief> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    try {
      final result = await _apiService.fetchWatchlist();
      setState(() {
        _items = result;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('관심종목 불러오기 실패: $e')),
      );
    }
  }

  void _toggleEdit() {
    setState(() {
      _editMode = !_editMode;
      _selected.clear();
    });
  }

  void _deleteSelected() async {
    final idsToDelete = _selected.toList();

    try {
      // 1. 서버에 삭제 요청
      for (final id in idsToDelete) {
        await _apiService2.removeFromWatchlist(id.toString());
        // StockItem.id 가 String이면 그대로, int면 toString() 필요
      }

      // 2. 로컬 리스트 갱신
      setState(() {
        _items.removeWhere((e) => _selected.contains(e.stockId));
        _selected.clear();
        if (_items.isEmpty) _editMode = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${idsToDelete.length}개 종목 삭제됨')),
      );
      watchlistChangedNotifier.value = true;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('삭제 실패: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          '관심 종목 편집',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        actions: [
          TextButton(
            onPressed: _items.isEmpty ? null : _toggleEdit,
            child: Text(
              _editMode ? '완료' : '편집',
              style: TextStyle(
                color: _items.isEmpty
                    ? theme.disabledColor
                    : Color(0xFF797979),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 서브헤더
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 5, 16, 5),
            child:Row(
              children: [
                if (_editMode) ...[
                  Checkbox(
                    value: _selected.length == _items.length && _items.isNotEmpty,
                    activeColor: Colors.black, // ✅ 체크박스 배경(체크됐을 때) 색상
                    checkColor: Colors.white,  // ✅ 체크 표시(✓) 색상
                    onChanged: (checked) {
                      setState(() {
                        if (checked == true) {
                          _selected.clear();
                          _selected.addAll(_items.map((e) => e.stockId));
                        } else {
                          _selected.clear();
                        }
                      });
                    },
                  ),
                  const Text(
                    '전체',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(width: 12),
                ] else ...[
                  Text(
                    '관심 ${_items.length}개',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF797979),
                    ),
                  ),
                ],

                const Spacer(),

                if (_editMode)
                  TextButton(
                    child: Text('삭제 (${_selected.length})'),
                    onPressed: _selected.isEmpty ? null : _deleteSelected,
                  ),
              ],
            ),
          ),
          // 리스트
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _items.isEmpty
                ? const EmptyState()
                : _editMode
                ? _buildReorderableList()
                : _buildNormalList(),
          ),
        ],
      ),
    );
  }

  Widget _buildNormalList() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 4),
      itemBuilder: (context, index) {
        final item = _items[index];
        return StockTile(
          item: item,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${item.stockName} 상세로 이동')),
            );
          },
          trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
        );
      },
    );
  }

  Widget _buildReorderableList() {
    return ReorderableListView.builder(
      buildDefaultDragHandles: false,
      padding: const EdgeInsets.symmetric(vertical: 3),
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final item = _items[index];
        final selected = _selected.contains(item.stockId);

        return Dismissible(
          key: ValueKey(item.stockId),
          background: Container(
            color: Colors.redAccent,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: const Icon(Icons.delete, color: Colors.black),
          ),
          direction: DismissDirection.endToStart,
          onDismissed: (_) {
            setState(() => _items.removeAt(index));
          },
          child: ReorderableDragStartListener(
            index: index,
            child: StockTile(
              item: item,
              leading: Checkbox(
                value: selected,
                activeColor: Colors.black,
                checkColor: Colors.white,
                onChanged: (v) {
                  setState(() {
                    if (v == true) {
                      _selected.add(item.stockId);
                    } else {
                      _selected.remove(item.stockId);
                    }
                  });
                },
              ),
              trailing: const Icon(Icons.drag_indicator_rounded,
                  color: Colors.grey),
              onTap: () {
                setState(() {
                  if (selected) {
                    _selected.remove(item.stockId);
                  } else {
                    _selected.add(item.stockId);
                  }
                });
              },
            ),
          ),
        );
      },
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (newIndex > oldIndex) newIndex -= 1;
          final moved = _items.removeAt(oldIndex);
          _items.insert(newIndex, moved);
        });
        // TODO: 서버 순서 업데이트 API 연동
      },
    );
  }
}
