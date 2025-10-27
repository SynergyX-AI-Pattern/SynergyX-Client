import 'package:flutter/foundation.dart';

/// 관심 종목 목록 갱신 트리거
final watchlistChangedNotifier = ValueNotifier<bool>(false);

/// 최근 종목 목록 갱신 트리거
final ValueNotifier<bool> recentRefreshNotifier = ValueNotifier(false);