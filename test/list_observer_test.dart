import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scrollview_observer/scrollview_observer.dart';

void main() {
  Widget getListView({
    ScrollController? scrollController,
    int itemCount = 100,
    bool isFixedHeight = false,
    double? cacheExtent,
  }) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: ListView.separated(
        controller: scrollController,
        itemBuilder: (ctx, index) {
          double height = 80;
          if (!isFixedHeight) {
            height = (index % 2 == 0) ? 80 : 50;
          }
          return SizedBox(
            height: height,
            child: Center(
              child: Text("index -- $index"),
            ),
          );
        },
        separatorBuilder: (ctx, index) {
          return const SizedBox(height: 10);
        },
        itemCount: itemCount,
        cacheExtent: cacheExtent,
      ),
    );
  }

  testWidgets('Auto get target sliver context', (tester) async {
    final scrollController = ScrollController();
    final observerController =
        ListObserverController(controller: scrollController);
    Widget widget = getListView(
      scrollController: scrollController,
    );
    widget = ListViewObserver(
      child: widget,
      controller: observerController,
    );
    await tester.pumpWidget(widget);
    expect(observerController.sliverContexts.length, 1);
    scrollController.dispose();
  });

  testWidgets('Scroll to index', (tester) async {
    final scrollController = ScrollController();
    final observerController =
        ListObserverController(controller: scrollController);

    Widget widget = getListView(
      scrollController: scrollController,
    );
    ListViewObserveModel? observeResult;
    widget = ListViewObserver(
      child: widget,
      controller: observerController,
      onObserve: (result) {
        observeResult = result;
      },
    );
    await tester.pumpWidget(widget);

    int targeItemIndex = 30;
    observerController.jumpTo(index: targeItemIndex);
    await tester.pumpAndSettle();
    expect(observeResult?.firstChild?.index, targeItemIndex);

    targeItemIndex = 60;
    observerController.animateTo(
      index: targeItemIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    await tester.pumpAndSettle();
    expect(observeResult?.firstChild?.index, targeItemIndex);

    scrollController.dispose();
  });

  group('Cache index offset', () {
    testWidgets('Property cacheJumpIndexOffset', (tester) async {
      final scrollController = ScrollController();
      final observerController =
          ListObserverController(controller: scrollController)
            ..cacheJumpIndexOffset = false;

      Widget widget = getListView(
        scrollController: scrollController,
      );
      widget = ListViewObserver(
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
          ListObserverController(controller: scrollController);

      Widget widget = getListView(
        scrollController: scrollController,
      );
      widget = ListViewObserver(
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
        ListObserverController(controller: scrollController);

    Widget widget = getListView(
      scrollController: scrollController,
    );

    bool isCalledOnObserve = false;
    widget = ListViewObserver(
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
      late ListObserverController observerController;
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
            ListObserverController(controller: scrollController);

        widget = getListView(
          scrollController: scrollController,
          itemCount: 100,
          isFixedHeight: isFixedHeight,
        );

        widget = ListViewObserver(
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
        'Notification sequence in normal scenarios with fixed item height',
        (tester) async {
          resetAll(isFixedHeight: true);
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

      testWidgets(
        'Notification sequence when using incorrect index with fixed item height',
        (tester) async {
          resetAll(isFixedHeight: true);
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
