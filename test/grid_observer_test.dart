import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scrollview_observer/scrollview_observer.dart';

void main() {
  Widget getGridView({
    ScrollController? scrollController,
  }) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: GridView.builder(
        controller: scrollController,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 2,
          mainAxisSpacing: 5,
        ),
        itemBuilder: (context, index) {
          return Container(
            color: Colors.blue[100],
            child: Center(
              child: Text('index -- $index'),
            ),
          );
        },
        itemCount: 200,
      ),
    );
  }

  testWidgets('Auto get target sliver context', (tester) async {
    final scrollController = ScrollController();
    final gridObserverController =
        GridObserverController(controller: scrollController);
    Widget widget = getGridView(
      scrollController: scrollController,
    );
    widget = GridViewObserver(
      child: widget,
      controller: gridObserverController,
    );
    await tester.pumpWidget(widget);
    expect(gridObserverController.sliverContexts.length, 1);
    scrollController.dispose();
  });

  testWidgets('Scroll to index', (tester) async {
    final scrollController = ScrollController();
    final gridObserverController =
        GridObserverController(controller: scrollController);

    Widget widget = getGridView(
      scrollController: scrollController,
    );
    GridViewObserveModel? observeResult;
    widget = GridViewObserver(
      child: widget,
      controller: gridObserverController,
      onObserve: (result) {
        observeResult = result;
      },
    );
    await tester.pumpWidget(widget);

    int targetItemIndex = 30;
    gridObserverController.jumpTo(index: targetItemIndex);
    await tester.pumpAndSettle();
    expect(
      (observeResult?.firstGroupChildList.map((e) => e.index) ?? [])
          .contains(targetItemIndex),
      true,
    );

    targetItemIndex = 60;
    gridObserverController.animateTo(
      index: targetItemIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    await tester.pumpAndSettle();
    expect(
      (observeResult?.firstGroupChildList.map((e) => e.index) ?? [])
          .contains(targetItemIndex),
      true,
    );

    scrollController.dispose();
  });
}
