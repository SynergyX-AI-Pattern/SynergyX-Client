import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stockapp/screens/search_info_screen.dart';
import 'package:stockapp/screens/chart_edit_screen.dart';
import 'package:stockapp/screens/chart_backtest_screen.dart';

class PatternDetailPage extends StatefulWidget {
  final String patternJson;
  final File imageFile;

  const PatternDetailPage({
    super.key,
    required this.patternJson,
    required this.imageFile,
  });

  @override
  State<PatternDetailPage> createState() => _PatternDetailPageState();
}

class _PatternDetailPageState extends State<PatternDetailPage> {
  late Map<String, dynamic> data;
  late List<dynamic> appliedStockList;
  late TextEditingController _titleController;

  @override
  void initState() {
    super.initState();
    data = jsonDecode(widget.patternJson);
    appliedStockList = List.from(data['appliedStockList'] ?? []);
    _titleController = TextEditingController(text: data['title'] ?? '이름없는 그래프');
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _saveTitle(String title) async {
    setState(() {
      data['title'] = title;
    });
    final ts = data['timestamp'];
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/pattern_$ts.json');
    await file.writeAsString(jsonEncode(data));
  }

  @override
  Widget build(BuildContext context) {
    final periodValue = data['periodValue'];
    final periodUnit = data['periodUnit'];
    final tolerance = double.parse(data['tolerance'].toString());
    final backtest = data['backtestResult'];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: '패턴 이름 입력',
                ),
                style: const TextStyle(color: Colors.black, fontSize: 18),
                onSubmitted: _saveTitle,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: () => _saveTitle(_titleController.text),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.play_arrow),
            tooltip: '백테스트 실행',
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChartBacktestScreen(patternData: data),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder:
                    (dialogContext) => AlertDialog(
                      title: const Text('삭제 확인'),
                      content: const Text('이 패턴을 삭제하시겠습니까?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext, false),
                          child: const Text('취소'),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.pop(dialogContext, true);
                            final ts = data['timestamp'];
                            final dir =
                                await getApplicationDocumentsDirectory();
                            final imageFile = File(
                              '${dir.path}/pattern_$ts.png',
                            );
                            final jsonFile = File(
                              '${dir.path}/pattern_$ts.json',
                            );
                            await Future.wait([
                              if (await imageFile.exists()) imageFile.delete(),
                              if (await jsonFile.exists()) jsonFile.delete(),
                            ]);
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (Navigator.canPop(context)) {
                                Navigator.pop(context, true);
                              }
                            });
                          },
                          child: const Text('삭제'),
                        ),
                      ],
                    ),
              );
              if (confirmed == true) {
                final ts = data['timestamp'];
                final dir = await getApplicationDocumentsDirectory();
                final imageFile = File('${dir.path}/pattern_$ts.png');
                final jsonFile = File('${dir.path}/pattern_$ts.json');
                await Future.wait([
                  if (await imageFile.exists()) imageFile.delete(),
                  if (await jsonFile.exists()) jsonFile.delete(),
                ]);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context, true);
                  }
                });
              }
            },
          ),
          ElevatedButton(
            onPressed: () async {
              final updated = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => ChartEditPage(
                        patternData: Map<String, dynamic>.from(data),
                        onSaved: () async {
                          final dir = await getApplicationDocumentsDirectory();
                          final ts = data['timestamp'];
                          final file = File('${dir.path}/pattern_$ts.json');
                          final updatedJson = await file.readAsString();
                          return updatedJson;
                        },
                      ),
                ),
              );

              if (!context.mounted) return;
              if (updated is String) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => PatternDetailPage(
                          patternJson: updated,
                          imageFile: widget.imageFile,
                        ),
                  ),
                );
              }
            },
            child: const Text('패턴 수정'),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child:
                  widget.imageFile.existsSync()
                      ? Image.file(widget.imageFile, fit: BoxFit.contain)
                      : const Center(
                        child: Icon(Icons.image_not_supported, size: 50),
                      ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '적용 종목:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const StockSearchPage(),
                          ),
                        );
                        if (result != null && result is String) {
                          final updatedData = Map<String, dynamic>.from(data);
                          if (updatedData['appliedStockList'] == null ||
                              updatedData['appliedStockList'] is! List) {
                            updatedData['appliedStockList'] = [];
                          }
                          final current = List<Map<String, dynamic>>.from(
                            updatedData['appliedStockList'],
                          );
                          final alreadyExists = current.any(
                            (item) => item['symbol'] == result,
                          );
                          if (!alreadyExists) {
                            current.add({'symbol': result, 'name': result});
                          }
                          updatedData['appliedStockList'] = current;

                          final dir = await getApplicationDocumentsDirectory();
                          final ts = data['timestamp'];
                          final file = File('${dir.path}/pattern_$ts.json');
                          await file.writeAsString(jsonEncode(updatedData));

                          if (!context.mounted) return;
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => PatternDetailPage(
                                    patternJson: jsonEncode(updatedData),
                                    imageFile: widget.imageFile,
                                  ),
                            ),
                          );
                        }
                      },
                      child: const Text('종목 변경'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                appliedStockList.isNotEmpty
                    ? Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children:
                          appliedStockList.asMap().entries.map<Widget>((entry) {
                            final index = entry.key;
                            final stock = entry.value;
                            return Chip(
                              label: Text(stock['name'] ?? stock['symbol']),
                              deleteIcon: const Icon(Icons.close),
                              onDeleted: () async {
                                setState(() {
                                  appliedStockList.removeAt(index);
                                  data['appliedStockList'] = appliedStockList;
                                });
                                final ts = data['timestamp'];
                                final dir =
                                    await getApplicationDocumentsDirectory();
                                final file = File(
                                  '${dir.path}/pattern_$ts.json',
                                );
                                await file.writeAsString(jsonEncode(data));
                              },
                            );
                          }).toList(),
                    )
                    : const Text('없음'),
                const SizedBox(height: 16),
                Text(
                  '기간: $periodValue $periodUnit',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  '오차 범위: ${tolerance.toStringAsFixed(1)}%',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                if (backtest != null) ...[
                  const Divider(),
                  const Text(
                    '백테스트 결과',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text('종목: ${backtest['stockName']} (${backtest['symbol']})'),
                  Text('매칭 횟수: ${backtest['matchedCount']}회'),
                  Text('승률: ${backtest['winRate']}%'),
                  Text('평균 수익률: ${backtest['averageReturn']}%'),
                  Text(
                    '최대 수익률: ${backtest['maxReturn']}% (${backtest['maxReturnDate']})',
                  ),
                  Text('기간: ${backtest['startDate']} ~ ${backtest['endDate']}'),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
