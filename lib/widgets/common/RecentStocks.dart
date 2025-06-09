import 'package:stockapp/models/StockItemModel.dart';

class RecentStocks {
  static final List<StockItem> _recent = [];

  static void add(StockItem stock) {
    // 이미 존재하면 제거 후 다시 추가 (중복 방지)
    _recent.removeWhere((item) => item.symbol == stock.symbol);
    _recent.insert(0, stock); // 가장 앞에 추가
    if (_recent.length > 3) {
      _recent.removeLast(); // 최대 3개 유지
    }
  }

  static List<StockItem> get recent => _recent;
}