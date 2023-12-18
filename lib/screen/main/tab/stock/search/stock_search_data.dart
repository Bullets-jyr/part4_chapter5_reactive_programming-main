import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../../common/common.dart';
import '../../../../../common/util/local_json.dart';
import '../vo/vo_simple_stock.dart';

class StockSearchData extends GetxController {
  List<SimpleStock> stocks = [];
  RxList<String> searchHistoryList = <String>[].obs;
  RxList<SimpleStock> searchResult = <SimpleStock>[].obs;

  int _searchCount = 0;

  /// [문제점]
  /// 유저가 검색 창에 키워드 입력할 때 마다 네트워킹 작업 필요
  /// '게임' 검색 시, 총 6번 호출

  StreamSubscription? _keywordSubscription;
  final PublishSubject<String> _keywordSubject = PublishSubject();

  @override
  void onInit() {
    super.onInit();

    searchHistoryList.addAll(['삼성전자', 'LG전자', '현대차', '넷플릭스']);
    () async {
      stocks.addAll(await LocalJson.getObjectList("stock_list.json"));
    }();

    /// TODO: debounce time 1s
    _keywordSubscription = _keywordSubject.debounceTime(const Duration(seconds: 1)).listen(
      (text) {
        _requestSearch(text);
      },
    );
  }

  Future<void> _requestSearch(String text) async {
    _searchCount++;
    debugPrint('Search count: $_searchCount, Network delay 0.5s');

    try {
      /// TODO: 가정 - 네트워킹 시간 0.5s
      await Future.delayed(const Duration(milliseconds: 500));
      final result = stocks.where((element) => element.stockName.contains(text)).toList();

      searchResult.value = result;
    } catch (e, s) {
      debugPrint(e.toString());
      debugPrint(s.toString());
    }
  }

  Future<void> changeKeyword(String text) async {
    _keywordSubject.add(text);

    if (isBlank(text)) {
      searchResult.clear();
      return;
    }
  }

  void addSearchHistory(String stockName) {
    searchHistoryList.insert(0, stockName);
  }

  @override
  void onClose() {
    _keywordSubscription?.cancel();
    _keywordSubject.close();

    super.onClose();
  }
}
