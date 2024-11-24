import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scrollview_observer/scrollview_observer.dart';
import 'package:scrollview_observer/src/common/observer_widget_tag_manager.dart';

void main() {
  Widget getListView({
    ScrollController? scrollController,
    int itemCount = 100,
    bool isFixedHeight = false,
    double? cacheExtent,
    NullableIndexedWidgetBuilder? itemBuilder,
  }) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: ListView.separated(
        controller: scrollController,
        itemBuilder: (ctx, index) {
          if (itemBuilder != null) {
            return itemBuilder(ctx, index);
          }
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

  Widget getFixedHeightListView({
    ScrollController? scrollController,
    int itemCount = 100,
    double? cacheExtent,
    bool useItemExtentBuilder = false,
  }) {
    const double height = 80;
    return Directionality(
      textDirection: TextDirection.ltr,
      child: ListView.builder(
        controller: scrollController,
        itemBuilder: (ctx, index) {
          return SizedBox(
            height: height,
            child: Center(
              child: Text("index -- $index"),
            ),
          );
        },
        itemExtent: useItemExtentBuilder ? null : height,
        itemExtentBuilder: useItemExtentBuilder
            ? (index, dimensions) {
                return height;
              }
            : null,
        itemCount: itemCount,
        cacheExtent: cacheExtent,
      ),
    );
  }

  testWidgets('Auto get target sliver context', (tester) async {
    final scrollController = ScrollController();
    final observerController = ListObserverController(
      controller: scrollController,
    );
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

  testWidgets('scrollNotificationPredicate', (tester) async {
    final scrollController = ScrollController();
    final observerController = ListObserverController(
      controller: scrollController,
    );
    final pageController = PageController();
    bool isCalledOnObserve = false;

    Widget widget = getListView(
      scrollController: scrollController,
      itemBuilder: (ctx, index) {
        if (index == 0) {
          return SizedBox(
            height: 200,
            child: PageView.builder(
              scrollDirection: Axis.horizontal,
              controller: pageController,
              itemBuilder: (ctx, index) {
                return const SizedBox.expand();
              },
              itemCount: 10,
            ),
          );
        }
        return const SizedBox(height: 80);
      },
    );
    widget = ListViewObserver(
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

  group('Scroll to index', () {
    testWidgets('Dynamic Height', (tester) async {
      final scrollController = ScrollController();
      final observerController = ListObserverController(
        controller: scrollController,
      );

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
      await tester.pump(observerController.observeIntervalForScrolling);
      expect(observeResult?.firstChild?.index, targeItemIndex);

      targeItemIndex = 60;
      observerController.animateTo(
        index: targeItemIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      await tester.pumpAndSettle();
      await tester.pump(observerController.observeIntervalForScrolling);
      expect(observeResult?.firstChild?.index, targeItemIndex);

      scrollController.dispose();
    });

    testWidgets('Fixed height with itemExtent', (tester) async {
      final scrollController = ScrollController();
      final observerController = ListObserverController(
        controller: scrollController,
      );

      Widget widget = getFixedHeightListView(
        scrollController: scrollController,
        useItemExtentBuilder: false,
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
      observerController.jumpTo(
        index: targeItemIndex,
        isFixedHeight: true,
      );
      await tester.pumpAndSettle();
      await tester.pump(observerController.observeIntervalForScrolling);
      expect(observeResult?.firstChild?.index, targeItemIndex);

      targeItemIndex = 60;
      observerController.animateTo(
        index: targeItemIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        isFixedHeight: true,
      );
      await tester.pumpAndSettle();
      await tester.pump(observerController.observeIntervalForScrolling);
      expect(observeResult?.firstChild?.index, targeItemIndex);

      scrollController.dispose();
    });

    testWidgets('Fixed height with itemExtentBuilder', (tester) async {
      final scrollController = ScrollController();
      final observerController =
          ListObserverController(controller: scrollController);

      Widget widget = getFixedHeightListView(
        scrollController: scrollController,
        useItemExtentBuilder: true,
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
      observerController.jumpTo(
        index: targeItemIndex,
        isFixedHeight: true,
      );
      await tester.pumpAndSettle();
      await tester.pump(observerController.observeIntervalForScrolling);
      expect(observeResult?.firstChild?.index, targeItemIndex);

      targeItemIndex = 60;
      observerController.animateTo(
        index: targeItemIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        isFixedHeight: true,
      );
      await tester.pumpAndSettle();
      await tester.pump(observerController.observeIntervalForScrolling);
      expect(observeResult?.firstChild?.index, targeItemIndex);

      scrollController.dispose();
    });
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
      await tester.pump(observerController.observeIntervalForScrolling);
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
      await tester.pump(observerController.observeIntervalForScrolling);
      expect(observerController.indexOffsetMap[ctx]?.isNotEmpty, true);

      observerController.clearScrollIndexCache();
      expect(observerController.indexOffsetMap[ctx]?.isEmpty, true);

      scrollController.dispose();
    });
  });

  testWidgets('Check displayPercentage', (tester) async {
    final scrollController = ScrollController();
    final observerController = ListObserverController(
      controller: scrollController,
    );

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

    int targetItemIndex = 30;
    observerController.jumpTo(
      index: targetItemIndex,
      alignment: 0,
    );
    await tester.pumpAndSettle();
    await tester.pump(observerController.observeIntervalForScrolling);
    var firstChild = observeResult?.firstChild;
    expect(firstChild, isNotNull);
    expect(firstChild?.index, targetItemIndex);
    expect(firstChild?.displayPercentage, 1);

    observerController.jumpTo(
      index: targetItemIndex,
      alignment: 0.5,
    );
    await tester.pumpAndSettle();
    await tester.pump(observerController.observeIntervalForScrolling);
    firstChild = observeResult?.firstChild;
    expect(firstChild?.index, targetItemIndex);
    expect(firstChild?.displayPercentage, 0.5);

    observerController.jumpTo(
      index: targetItemIndex,
      alignment: 1,
    );
    await tester.pumpAndSettle();
    await tester.pump(observerController.observeIntervalForScrolling);
    firstChild = observeResult?.firstChild;
    expect(firstChild?.index, targetItemIndex + 1);

    scrollController.dispose();
  });

  testWidgets('Check observeIntervalForScrolling', (tester) async {
    final scrollController = ScrollController();
    final observerController = ListObserverController(
      controller: scrollController,
    )..observeIntervalForScrolling = const Duration(milliseconds: 500);
    int observeCount = 0;

    Widget widget = getListView(
      scrollController: scrollController,
    );
    widget = ListViewObserver(
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
    await tester.pump(observerController.observeIntervalForScrolling);
    expect(isCalledOnObserve, false);

    observerController.isForbidObserveCallback = false;
    observerController.jumpTo(index: 30);
    await tester.pumpAndSettle();
    await tester.pump(observerController.observeIntervalForScrolling);
    expect(isCalledOnObserve, true);

    scrollController.dispose();
  });

  testWidgets('Check displayingChildModelMap', (tester) async {
    final scrollController = ScrollController();
    final observerController = ListObserverController(
      controller: scrollController,
    );

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
    await observerController.dispatchOnceObserve(
      isForce: true,
    );
    expect(observeResult, isNotNull);
    expect(observeResult?.firstChild?.index, 0);
    expect(
      listEquals(
        observeResult?.displayingChildModelMap.values.toList(),
        observeResult?.displayingChildModelList,
      ),
      true,
    );

    int targetItemIndex = 30;
    observerController.jumpTo(
      index: targetItemIndex,
      alignment: 0,
    );
    await tester.pumpAndSettle();
    await tester.pump(observerController.observeIntervalForScrolling);
    expect(observeResult?.firstChild?.index, targetItemIndex);
    expect(
      listEquals(
        observeResult?.displayingChildModelMap.values.toList(),
        observeResult?.displayingChildModelList,
      ),
      true,
    );

    scrollController.dispose();
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
        observerController = ListObserverController(
          controller: scrollController,
        );

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
          await tester.pump(observerController.observeIntervalForScrolling);
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

  group('dispatchOnceObserve', () {
    late ScrollController scrollController;
    late ListObserverController observerController;
    late Widget widget;

    tearDown(() {
      scrollController.dispose();
    });

    resetAll() {
      scrollController = ScrollController();
      observerController = ListObserverController(
        controller: scrollController,
      );
      widget = getListView(
        scrollController: scrollController,
        itemCount: 100,
      );
      widget = ListViewObserver(
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

  group('ObserverListener', () {
    late String tag1;
    late String tag2;
    late GlobalKey key1;
    late GlobalKey key2;
    late ScrollController scrollController;
    late ListObserverController observerController1;
    late ListObserverController observerController2;
    late Widget widget;

    tearDown(() {
      scrollController.dispose();
    });

    resetAll({
      bool isResetTag = false,
    }) {
      if (isResetTag) {
        tag1 = tag1 * 2;
        tag2 = tag2 * 2;
      } else {
        tag1 = 'tag1';
        tag2 = 'tag2';
        key1 = GlobalKey();
        key2 = GlobalKey();
        scrollController = ScrollController();
        observerController1 = ListObserverController(
          controller: scrollController,
        );
        observerController2 = ListObserverController(
          controller: scrollController,
        );
      }
      widget = getListView(
        scrollController: scrollController,
        itemCount: 100,
        itemBuilder: (context, index) {
          if (index == 3) {
            return const SizedBox(
              height: 50,
              child: Center(
                child: Icon(Icons.abc),
              ),
            );
          }
          return SizedBox(
            height: 80,
            child: Center(
              child: Text("index -- $index"),
            ),
          );
        },
      );
      widget = ListViewObserver(
        key: key2,
        tag: tag2,
        child: widget,
        controller: observerController2,
      );
      widget = ListViewObserver(
        key: key1,
        tag: tag1,
        child: widget,
        controller: observerController1,
      );
    }

    testWidgets('Change tag', (tester) async {
      resetAll();
      await tester.pumpWidget(widget);

      final itemFinder = find.byIcon(Icons.abc);

      ObserverWidgetTagManager? tagManager = ObserverWidgetTagManager.maybeOf(
        tester.element(itemFinder),
      );
      expect(tagManager, isNotNull);

      Map<String, BuildContext> tagMap = Map.from(tagManager?.tagMap ?? {});
      Set<String> tags = {tag1, tag2};
      expect(tagMap.keys.toSet(), tags);

      resetAll(isResetTag: true);
      await tester.pumpWidget(widget);

      tagManager = ObserverWidgetTagManager.maybeOf(
        tester.element(itemFinder),
      );
      tagMap = Map.from(tagManager?.tagMap ?? {});
      Set<String> newTags = {tag1, tag2};
      expect(tags != newTags, isTrue);
      expect(tagMap.keys.toSet(), newTags);
    });

    testWidgets('of', (tester) async {
      resetAll();
      await tester.pumpWidget(widget);

      final itemFinder = find.byIcon(Icons.abc);

      ListViewObserveModel? cbResult;
      Map<BuildContext, ListViewObserveModel>? cbAllResult;
      onObserveCallback(ListViewObserveModel result) {
        cbResult = result;
      }

      onObserveAllCallback(
        Map<BuildContext, ListViewObserveModel> resultMap,
      ) {
        cbAllResult = resultMap;
      }

      final observerState = ListViewObserver.of(
        tester.element(itemFinder),
      );
      expect(observerState, isNotNull);

      final observerStateByTag2 = ListViewObserver.of(
        tester.element(itemFinder),
        tag: tag2,
      );
      expect(observerStateByTag2 == key2.currentState, isTrue);
      expect(observerStateByTag2 == observerState, isTrue);

      final observerStateByTag1 = ListViewObserver.of(
        tester.element(itemFinder),
        tag: tag1,
      );
      expect(observerStateByTag1 == key1.currentState, isTrue);
      expect(observerStateByTag1 == observerState, isFalse);

      observerState.addListener(
        onObserve: onObserveCallback,
        onObserveAll: onObserveAllCallback,
      );
      expect(observerState.innerListeners?.length, 1);

      final result = await observerController2.dispatchOnceObserve();
      expect(result.observeResult, cbResult);
      expect(result.observeAllResult, cbAllResult);

      observerState.removeListener(
        onObserve: onObserveCallback,
        onObserveAll: onObserveAllCallback,
      );
      expect(observerState.innerListeners?.length, 0);
    });

    testWidgets('maybeOf', (tester) async {
      resetAll();
      await tester.pumpWidget(widget);
      final itemFinder = find.byIcon(Icons.abc);

      ListViewObserverState? observerState = ListViewObserver.maybeOf(
        tester.element(find.byKey(key1)),
      );
      expect(observerState, isNull);

      ListViewObserveModel? cbResult;
      Map<BuildContext, ListViewObserveModel>? cbAllResult;
      onObserveCallback(ListViewObserveModel result) {
        cbResult = result;
      }

      onObserveAllCallback(
        Map<BuildContext, ListViewObserveModel> resultMap,
      ) {
        cbAllResult = resultMap;
      }

      observerState = ListViewObserver.maybeOf(
        tester.element(itemFinder),
      );
      expect(observerState, isNotNull);

      final observerStateByTag2 = ListViewObserver.maybeOf(
        tester.element(itemFinder),
        tag: tag2,
      );
      expect(observerStateByTag2 == key2.currentState, isTrue);
      expect(observerStateByTag2 == observerState, isTrue);

      final observerStateByTag1 = ListViewObserver.maybeOf(
        tester.element(itemFinder),
        tag: tag1,
      );
      expect(observerStateByTag1 == key1.currentState, isTrue);
      expect(observerStateByTag1 == observerState, isFalse);

      observerState?.addListener(
        onObserve: onObserveCallback,
        onObserveAll: onObserveAllCallback,
      );
      expect(observerState?.innerListeners?.length, 1);

      final result = await observerController2.dispatchOnceObserve();
      expect(result.observeResult, cbResult);
      expect(result.observeAllResult, cbAllResult);

      observerState?.removeListener(
        onObserve: onObserveCallback,
        onObserveAll: onObserveAllCallback,
      );
      expect(observerState?.innerListeners?.length, 0);
    });
  });
}
