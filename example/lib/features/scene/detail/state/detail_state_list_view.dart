/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/fluttercandies/flutter_scrollview_observer
 * @Date: 2025-08-03 22:01:50
 */

import 'package:flutter/material.dart';
import 'package:scrollview_observer/scrollview_observer.dart';
import 'package:scrollview_observer_example/features/scene/detail/header/detail_header.dart';

mixin DetailStateForListView {
  DetailModuleType? defaultModuleAnchor;

  List<DetailModuleType> moduleTypes = DetailModuleType.values.toList();

  ScrollController scrollController = ScrollController();

  late ListObserverController observerController = ListObserverController(
    controller: scrollController,
  )..cacheJumpIndexOffset = false;

  late ChatScrollObserver keepPositionObserver = ChatScrollObserver(
    observerController,
  )..fixedPositionOffset = -1;

  List<DetailModuleType> asyncLoadModuleTypes = [
    DetailModuleType.module3,
    DetailModuleType.module6,
  ];

  bool haveDataForModule3 = false;

  bool haveDataForModule6 = false;
}
