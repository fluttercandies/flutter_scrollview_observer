/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/fluttercandies/flutter_scrollview_observer
 * @Date: 2024-05-20 22:19:27
 */

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scrollview_observer/scrollview_observer.dart';

void main() {
  testWidgets('check calcAnchorTabIndex', (tester) async {
    final scrollController = ScrollController();
    final observerController = ListObserverController(
      controller: scrollController,
    );
    ObserveModel? observeModel;
    Widget widget = Directionality(
      textDirection: TextDirection.ltr,
      child: ListView.separated(
        controller: scrollController,
        itemBuilder: (ctx, index) {
          return const SizedBox(
            width: double.infinity,
            height: 80,
          );
        },
        separatorBuilder: (ctx, index) {
          return const SizedBox(height: 10);
        },
        itemCount: 100,
      ),
    );
    widget = ListViewObserver(
      child: widget,
      controller: observerController,
      onObserve: (resultModel) => observeModel = resultModel,
    );
    await tester.pumpWidget(widget);

    observerController.jumpTo(index: 5);
    await tester.pumpAndSettle();
    expect(observeModel, isNotNull);
    List<int> tabIndexes = [0, 5, 10];
    int tabIndex = ObserverUtils.calcAnchorTabIndex(
      observeModel: observeModel!,
      tabIndexs: tabIndexes,
      currentTabIndex: 0,
    );
    expect(tabIndex, 1);

    observerController.jumpTo(index: 9);
    await tester.pumpAndSettle();
    tabIndex = ObserverUtils.calcAnchorTabIndex(
      observeModel: observeModel!,
      tabIndexs: tabIndexes,
      currentTabIndex: 1,
    );
    expect(tabIndex, 1);

    scrollController.dispose();
  });
}
