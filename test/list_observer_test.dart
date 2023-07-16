import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scrollview_observer/scrollview_observer.dart';

void main() {
  Widget getListView({
    ScrollController? scrollController,
  }) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: ListView.separated(
        controller: scrollController,
        itemBuilder: (ctx, index) {
          return SizedBox(
            height: (index % 2 == 0) ? 80 : 50,
            child: Center(
              child: Text("index -- $index"),
            ),
          );
        },
        separatorBuilder: (ctx, index) {
          return const SizedBox(height: 10);
        },
        itemCount: 100,
        cacheExtent: double.maxFinite,
      ),
    );
  }

  testWidgets('Auto get target sliver context', (tester) async {
    final scrollController = ScrollController();
    final listObserverController =
        ListObserverController(controller: scrollController);
    Widget widget = getListView(
      scrollController: scrollController,
    );
    widget = ListViewObserver(
      child: widget,
      controller: listObserverController,
    );
    await tester.pumpWidget(widget);
    expect(listObserverController.sliverContexts.length, 1);
    scrollController.dispose();
  });

  testWidgets('Scroll to index', (tester) async {
    final scrollController = ScrollController();
    final listObserverController =
        ListObserverController(controller: scrollController);

    Widget widget = getListView(
      scrollController: scrollController,
    );
    ListViewObserveModel? observeResult;
    widget = ListViewObserver(
      child: widget,
      controller: listObserverController,
      onObserve: (result) {
        observeResult = result;
      },
    );
    await tester.pumpWidget(widget);

    int targeItemIndex = 30;
    listObserverController.jumpTo(index: targeItemIndex);
    await tester.pumpAndSettle();
    expect(observeResult?.firstChild?.index, targeItemIndex);

    targeItemIndex = 60;
    listObserverController.animateTo(
      index: targeItemIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    await tester.pumpAndSettle();
    expect(observeResult?.firstChild?.index, targeItemIndex);

    scrollController.dispose();
  });
}
