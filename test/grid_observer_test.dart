import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scrollview_observer/scrollview_observer.dart';

void main() {
  Widget getGridView({
    ScrollController? scrollController,
    int itemCount = 200,
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
        itemCount: itemCount,
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

  group('Cache index offset', () {
    testWidgets('Property cacheJumpIndexOffset', (tester) async {
      final scrollController = ScrollController();
      final observerController =
          GridObserverController(controller: scrollController)
            ..cacheJumpIndexOffset = false;

      Widget widget = getGridView(
        scrollController: scrollController,
      );
      widget = GridViewObserver(
        child: widget,
        controller: observerController,
      );
      await tester.pumpWidget(widget);

      observerController.jumpTo(index: 30);
      await tester.pumpAndSettle();
      expect(observerController.indexOffsetMap.isEmpty, true);

      scrollController.dispose();
    });

    testWidgets('Method clearScrollIndexCache', (tester) async {
      final scrollController = ScrollController();
      final observerController =
          GridObserverController(controller: scrollController);

      Widget widget = getGridView(
        scrollController: scrollController,
      );
      widget = GridViewObserver(
        child: widget,
        controller: observerController,
      );
      await tester.pumpWidget(widget);

      final ctx = observerController.fetchSliverContext();
      expect(ctx != null, true);

      observerController.jumpTo(index: 30);
      await tester.pumpAndSettle();
      expect(observerController.indexOffsetMap[ctx]?.isNotEmpty, true);

      observerController.clearScrollIndexCache();
      expect(observerController.indexOffsetMap[ctx]?.isEmpty, true);

      scrollController.dispose();
    });
  });

  testWidgets('Check isForbidObserveCallback', (tester) async {
    final scrollController = ScrollController();
    final observerController =
        GridObserverController(controller: scrollController);

    Widget widget = getGridView(
      scrollController: scrollController,
    );

    bool isCalledOnObserve = false;
    widget = GridViewObserver(
      child: widget,
      controller: observerController,
      onObserve: (result) {
        isCalledOnObserve = true;
      },
    );
    await tester.pumpWidget(widget);

    observerController.isForbidObserveCallback = true;
    observerController.jumpTo(index: 10);
    await tester.pumpAndSettle();
    expect(isCalledOnObserve, false);

    observerController.isForbidObserveCallback = false;
    observerController.jumpTo(index: 30);
    await tester.pumpAndSettle();
    expect(isCalledOnObserve, true);
  });

  group(
    'ObserverScrollNotification',
    () {
      late ScrollController scrollController;
      late GridObserverController observerController;
      late Widget widget;

      int indexOfStartNoti = -1;
      int indexOfInterruptionNoti = -1;
      int indexOfDecisionNoti = -1;
      int indexOfEndNoti = -1;

      resetAll({
        bool isFixedHeight = false,
      }) {
        indexOfStartNoti = -1;
        indexOfInterruptionNoti = -1;
        indexOfDecisionNoti = -1;
        indexOfEndNoti = -1;
        scrollController = ScrollController();
        observerController =
            GridObserverController(controller: scrollController);

        widget = getGridView(
          scrollController: scrollController,
          itemCount: 100,
        );

        widget = GridViewObserver(
          child: widget,
          controller: observerController,
        );
        int count = 0;
        widget = NotificationListener<ObserverScrollNotification>(
          child: widget,
          onNotification: (notification) {
            if (notification is ObserverScrollStartNotification) {
              indexOfStartNoti = count;
            } else if (notification is ObserverScrollInterruptionNotification) {
              indexOfInterruptionNoti = count;
            } else if (notification is ObserverScrollDecisionNotification) {
              indexOfDecisionNoti = count;
            } else if (notification is ObserverScrollEndNotification) {
              indexOfEndNoti = count;
            }
            count += 1;
            return true;
          },
        );
      }

      tearDown(() {
        scrollController.dispose();
      });

      testWidgets(
        'Notification sequence in normal scenarios',
        (tester) async {
          resetAll();
          await tester.pumpWidget(widget);
          observerController.jumpTo(index: 10);
          await tester.pumpAndSettle();
          expect(indexOfStartNoti, 0);
          expect(indexOfInterruptionNoti, -1);
          expect(indexOfDecisionNoti, 1);
          expect(indexOfEndNoti, 2);
        },
      );

      testWidgets(
        'Notification sequence when using incorrect index',
        (tester) async {
          resetAll();
          await tester.pumpWidget(widget);
          observerController.jumpTo(index: 101);
          await tester.pumpAndSettle();
          expect(indexOfStartNoti, 0);
          expect(indexOfInterruptionNoti, 1);
          expect(indexOfDecisionNoti, -1);
          expect(indexOfEndNoti, -1);
        },
      );
    },
  );
}
