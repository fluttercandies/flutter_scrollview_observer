import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scrollview_observer/scrollview_observer.dart';

void main() {
  Widget getGridView({
    ScrollController? scrollController,
    int itemCount = 200,
    NullableIndexedWidgetBuilder? itemBuilder,
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
          if (itemBuilder != null) {
            return itemBuilder(context, index);
          }
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
    final gridObserverController = GridObserverController(
      controller: scrollController,
    );
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

  testWidgets('scrollNotificationPredicate', (tester) async {
    final scrollController = ScrollController();
    final observerController = GridObserverController(
      controller: scrollController,
    );
    final pageController = PageController();
    bool isCalledOnObserve = false;

    Widget widget = getGridView(
      scrollController: scrollController,
      itemBuilder: (ctx, index) {
        if (index == 0) {
          return PageView.builder(
            scrollDirection: Axis.horizontal,
            controller: pageController,
            itemBuilder: (ctx, index) {
              return const SizedBox.expand();
            },
            itemCount: 10,
          );
        }
        return const SizedBox.expand();
      },
    );
    widget = GridViewObserver(
      child: widget,
      controller: observerController,
      scrollNotificationPredicate: defaultScrollNotificationPredicate,
      onObserve: (result) {
        isCalledOnObserve = true;
      },
    );
    await tester.pumpWidget(widget);

    pageController.animateToPage(
      3,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeInOut,
    );
    await tester.pumpAndSettle();
    expect(pageController.page, 3);
    expect(isCalledOnObserve, isFalse);

    scrollController.animateTo(
      10,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeInOut,
    );
    expect(isCalledOnObserve, isTrue);

    scrollController.dispose();
    pageController.dispose();
  });

  testWidgets('Scroll to index', (tester) async {
    final scrollController = ScrollController();
    final gridObserverController = GridObserverController(
      controller: scrollController,
    );

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
      final observerController = GridObserverController(
        controller: scrollController,
      )..cacheJumpIndexOffset = false;

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
      await tester.pump(observerController.observeIntervalForScrolling);
      expect(observerController.indexOffsetMap.isEmpty, true);

      scrollController.dispose();
    });

    testWidgets('Method clearScrollIndexCache', (tester) async {
      final scrollController = ScrollController();
      final observerController = GridObserverController(
        controller: scrollController,
      );

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
      await tester.pump(observerController.observeIntervalForScrolling);
      expect(observerController.indexOffsetMap[ctx]?.isNotEmpty, true);

      observerController.clearScrollIndexCache();
      expect(observerController.indexOffsetMap[ctx]?.isEmpty, true);

      scrollController.dispose();
    });
  });

  testWidgets('Check displayPercentage', (tester) async {
    final scrollController = ScrollController();
    final observerController = GridObserverController(
      controller: scrollController,
    );

    Widget widget = getGridView(
      scrollController: scrollController,
    );
    GridViewObserveModel? observeResult;
    widget = GridViewObserver(
      child: widget,
      controller: observerController,
      onObserve: (result) {
        observeResult = result;
      },
    );
    await tester.pumpWidget(widget);

    int targetItemIndex = 30;
    observerController.jumpTo(
      index: targetItemIndex,
      alignment: 0,
    );
    await tester.pumpAndSettle();
    var firstGroupChildList = observeResult?.firstGroupChildList ?? [];
    expect(firstGroupChildList, isNotEmpty);
    expect(firstGroupChildList.first.index, targetItemIndex);
    expect(firstGroupChildList.first.displayPercentage, 1);

    observerController.jumpTo(
      index: targetItemIndex,
      alignment: 0.5,
    );
    await tester.pumpAndSettle();
    firstGroupChildList = observeResult?.firstGroupChildList ?? [];
    expect(firstGroupChildList.first.index, targetItemIndex);
    expect(firstGroupChildList.first.displayPercentage, 0.5);

    observerController.jumpTo(
      index: targetItemIndex,
      alignment: 1,
    );
    await tester.pumpAndSettle();
    firstGroupChildList = observeResult?.firstGroupChildList ?? [];
    expect(firstGroupChildList.first.index, targetItemIndex + 2);

    scrollController.dispose();
  });

  testWidgets('Check observeIntervalForScrolling', (tester) async {
    final scrollController = ScrollController();
    final observerController = GridObserverController(
      controller: scrollController,
    )..observeIntervalForScrolling = const Duration(milliseconds: 500);
    int observeCount = 0;

    Widget widget = getGridView(
      scrollController: scrollController,
    );
    widget = GridViewObserver(
      child: widget,
      controller: observerController,
      autoTriggerObserveTypes: const [
        ObserverAutoTriggerObserveType.scrollStart,
        ObserverAutoTriggerObserveType.scrollUpdate,
        ObserverAutoTriggerObserveType.scrollEnd,
      ],
      triggerOnObserveType: ObserverTriggerOnObserveType.directly,
      onObserve: (result) {
        observeCount++;
      },
    );
    await tester.pumpWidget(widget);
    final finder = find.byWidget(widget);

    await tester.timedDragFrom(
      tester.getCenter(finder),
      const Offset(0, -50),
      const Duration(milliseconds: 400),
    );
    await tester.pumpAndSettle();
    await tester.pump(observerController.observeIntervalForScrolling);
    expect(observeCount, 3);

    observeCount = 0;
    await tester.timedDragFrom(
      tester.getCenter(finder),
      const Offset(0, -50),
      const Duration(milliseconds: 600),
    );
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 600));
    expect(observeCount, 4);

    scrollController.dispose();
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
    await tester.pump(observerController.observeIntervalForScrolling);
    expect(isCalledOnObserve, false);

    observerController.isForbidObserveCallback = false;
    observerController.jumpTo(index: 30);
    await tester.pumpAndSettle();
    await tester.pump(observerController.observeIntervalForScrolling);
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
          await tester.pump(observerController.observeIntervalForScrolling);
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
          await tester.pump(observerController.observeIntervalForScrolling);
          expect(indexOfStartNoti, 0);
          expect(indexOfInterruptionNoti, 1);
          expect(indexOfDecisionNoti, -1);
          expect(indexOfEndNoti, -1);
        },
      );
    },
  );

  group('dispatchOnceObserve', () {
    late ScrollController scrollController;
    late GridObserverController observerController;
    late Widget widget;

    tearDown(() {
      scrollController.dispose();
    });

    resetAll() {
      scrollController = ScrollController();
      observerController = GridObserverController(
        controller: scrollController,
      );
      widget = getGridView(
        scrollController: scrollController,
        itemCount: 100,
      );
      widget = GridViewObserver(
        child: widget,
        controller: observerController,
      );
    }

    testWidgets(
      'Check observeResult',
      (tester) async {
        resetAll();
        await tester.pumpWidget(widget);
        var result = await observerController.dispatchOnceObserve();
        expect(result.isSuccess, isFalse);

        result = await observerController.dispatchOnceObserve(
          isDependObserveCallback: false,
        );
        expect(result.isSuccess, isTrue);
        expect(result.observeResult, isNotNull);
        expect(
          result.observeResult?.displayingChildIndexList ?? [],
          isNotEmpty,
        );

        result = await observerController.dispatchOnceObserve(
          isDependObserveCallback: false,
        );
        expect(result.isSuccess, isTrue);
        expect(
          result.observeResult?.displayingChildIndexList ?? [],
          isEmpty,
        );

        result = await observerController.dispatchOnceObserve(
          isDependObserveCallback: false,
          isForce: true,
        );
        expect(result.isSuccess, isTrue);
        expect(
          result.observeResult?.displayingChildIndexList ?? [],
          isNotEmpty,
        );
      },
    );

    testWidgets(
      'Check observeAllResult',
      (tester) async {
        resetAll();
        await tester.pumpWidget(widget);
        var result = await observerController.dispatchOnceObserve();
        expect(result.isSuccess, isFalse);

        result = await observerController.dispatchOnceObserve(
          isDependObserveCallback: false,
        );
        expect(result.isSuccess, isTrue);
        expect(result.observeAllResult.values.length, 1);
        expect(
          result.observeAllResult.values.first,
          result.observeResult,
        );

        result = await observerController.dispatchOnceObserve(
          isDependObserveCallback: false,
        );
        expect(result.isSuccess, isTrue);
        expect(result.observeAllResult, isEmpty);

        result = await observerController.dispatchOnceObserve(
          isDependObserveCallback: false,
          isForce: true,
        );
        expect(result.isSuccess, isTrue);
        expect(result.observeAllResult, isNotEmpty);
      },
    );
  });
}
