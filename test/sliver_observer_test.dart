import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scrollview_observer/scrollview_observer.dart';
import 'package:scrollview_observer/src/common/observer_widget_tag_manager.dart';

void main() {
  GlobalKey sliverListKey = GlobalKey();
  GlobalKey sliverGridKey = GlobalKey();
  BuildContext? _sliverListCtx;
  BuildContext? _sliverGridCtx;

  double calcPersistentHeaderExtent({
    required double offset,
    required GlobalKey widgetKey,
  }) {
    return ObserverUtils.calcPersistentHeaderExtent(
      key: widgetKey,
      offset: offset,
    );
  }

  Widget _buildDirectionality({
    required Widget child,
  }) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: child,
    );
  }

  Widget _buildSliverListView({
    NullableIndexedWidgetBuilder? builder,
  }) {
    return SliverList(
      key: sliverListKey,
      delegate: SliverChildBuilderDelegate(
        (ctx, index) {
          _sliverListCtx ??= ctx;
          if (builder != null) {
            return builder(ctx, index);
          }
          return Container(
            height: (index % 2 == 0) ? 80 : 50,
            color: Colors.red,
            child: Center(
              child: Text("index -- $index"),
            ),
          );
        },
        childCount: 30,
      ),
    );
  }

  Widget _buildSliverGridView({
    NullableIndexedWidgetBuilder? builder,
  }) {
    return SliverGrid(
      key: sliverGridKey,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10.0,
        crossAxisSpacing: 10.0,
        childAspectRatio: 2.0,
      ),
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          _sliverGridCtx ??= context;
          if (builder != null) {
            return builder(context, index);
          }
          return Container(
            color: Colors.green,
            child: Center(
              child: Text('index -- $index'),
            ),
          );
        },
        childCount: 150,
      ),
    );
  }

  Widget _buildScrollView({
    ScrollController? scrollController,
    NullableIndexedWidgetBuilder? listItemBuilder,
    NullableIndexedWidgetBuilder? gridItemBuilder,
  }) {
    return _buildDirectionality(
      child: CustomScrollView(
        controller: scrollController,
        slivers: [
          _buildSliverListView(
            builder: listItemBuilder,
          ),
          _buildSliverGridView(
            builder: gridItemBuilder,
          ),
        ],
      ),
    );
  }

  tearDown(() {
    _sliverListCtx = null;
    _sliverGridCtx = null;
  });

  testWidgets('Check isForbidObserveCallback', (tester) async {
    final scrollController = ScrollController();
    final observerController = SliverObserverController(
      controller: scrollController,
    );

    Widget widget = _buildScrollView(
      scrollController: scrollController,
    );

    bool isCalledOnObserve = false;
    widget = SliverViewObserver(
      child: widget,
      controller: observerController,
      sliverContexts: () {
        return [
          if (_sliverListCtx != null) _sliverListCtx!,
          if (_sliverGridCtx != null) _sliverGridCtx!,
        ];
      },
      onObserveAll: (result) {
        isCalledOnObserve = true;
      },
    );
    await tester.pumpWidget(widget);

    observerController.isForbidObserveCallback = true;
    observerController.jumpTo(index: 10, sliverContext: _sliverListCtx);
    await tester.pumpAndSettle();
    await tester.pump(observerController.observeIntervalForScrolling);
    expect(isCalledOnObserve, false);

    observerController.isForbidObserveCallback = false;
    observerController.jumpTo(index: 20, sliverContext: _sliverListCtx);
    await tester.pumpAndSettle();
    await tester.pump(observerController.observeIntervalForScrolling);
    expect(isCalledOnObserve, true);

    scrollController.dispose();
  });

  testWidgets('Check isForbidObserveViewportCallback', (tester) async {
    final scrollController = ScrollController();
    final observerController = SliverObserverController(
      controller: scrollController,
    );

    Widget widget = _buildScrollView(
      scrollController: scrollController,
    );

    bool isCalledOnObserveViewport = false;
    widget = SliverViewObserver(
      child: widget,
      controller: observerController,
      sliverContexts: () {
        return [
          if (sliverListKey.currentContext != null)
            sliverListKey.currentContext!,
          if (sliverGridKey.currentContext != null)
            sliverGridKey.currentContext!,
        ];
      },
      onObserveViewport: (result) {
        isCalledOnObserveViewport = true;
      },
    );
    await tester.pumpWidget(widget);

    observerController.isForbidObserveViewportCallback = true;
    observerController.jumpTo(index: 10, sliverContext: _sliverListCtx);
    await tester.pumpAndSettle();
    await tester.pump(observerController.observeIntervalForScrolling);
    expect(isCalledOnObserveViewport, false);

    observerController.isForbidObserveViewportCallback = false;
    observerController.jumpTo(index: 20, sliverContext: _sliverGridCtx);
    await tester.pumpAndSettle();
    await tester.pump(observerController.observeIntervalForScrolling);
    expect(isCalledOnObserveViewport, true);

    scrollController.dispose();
  });

  testWidgets('Check observeIntervalForScrolling', (tester) async {
    final scrollController = ScrollController();
    final observerController = SliverObserverController(
      controller: scrollController,
    )..observeIntervalForScrolling = const Duration(milliseconds: 500);
    int observeCountForOnObserveAll = 0;
    int observeCountForOnObserveViewport = 0;

    Widget widget = _buildScrollView(
      scrollController: scrollController,
    );

    widget = SliverViewObserver(
      child: widget,
      controller: observerController,
      sliverContexts: () {
        return [
          if (sliverListKey.currentContext != null)
            sliverListKey.currentContext!,
          if (sliverGridKey.currentContext != null)
            sliverGridKey.currentContext!,
        ];
      },
      autoTriggerObserveTypes: const [
        ObserverAutoTriggerObserveType.scrollStart,
        ObserverAutoTriggerObserveType.scrollUpdate,
        ObserverAutoTriggerObserveType.scrollEnd,
      ],
      triggerOnObserveType: ObserverTriggerOnObserveType.directly,
      onObserveAll: (_) {
        observeCountForOnObserveAll++;
      },
      onObserveViewport: (_) {
        observeCountForOnObserveViewport++;
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
    expect(observeCountForOnObserveAll, 3);
    expect(observeCountForOnObserveViewport, 3);

    observeCountForOnObserveAll = 0;
    observeCountForOnObserveViewport = 0;
    await tester.timedDragFrom(
      tester.getCenter(finder),
      const Offset(0, -50),
      const Duration(milliseconds: 600),
    );
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 600));
    expect(observeCountForOnObserveAll, 4);
    expect(observeCountForOnObserveViewport, 4);

    scrollController.dispose();
  });

  testWidgets('scrollNotificationPredicate', (tester) async {
    final scrollController = ScrollController();
    final observerController = SliverObserverController(
      controller: scrollController,
    );
    final pageController = PageController();
    bool isCalledOnObserve = false;

    Widget widget = _buildScrollView(
      scrollController: scrollController,
      listItemBuilder: (context, index) {
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
    widget = SliverViewObserver(
      child: widget,
      controller: observerController,
      scrollNotificationPredicate: defaultScrollNotificationPredicate,
      sliverContexts: () {
        return [
          if (_sliverListCtx != null) _sliverListCtx!,
          if (_sliverGridCtx != null) _sliverGridCtx!,
        ];
      },
      onObserveAll: (result) {
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
    await tester.pump(observerController.observeIntervalForScrolling);
    expect(pageController.page, 3);
    expect(isCalledOnObserve, isFalse);

    scrollController.animateTo(
      10,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeInOut,
    );
    await tester.pumpAndSettle();
    await tester.pump(observerController.observeIntervalForScrolling);
    expect(isCalledOnObserve, isTrue);

    scrollController.dispose();
    pageController.dispose();
  });

  group(
    'ObserverScrollNotification',
    () {
      late ScrollController scrollController;
      late SliverObserverController observerController;
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
        observerController = SliverObserverController(
          controller: scrollController,
        );

        widget = _buildScrollView(
          scrollController: scrollController,
        );

        widget = SliverViewObserver(
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
    late SliverObserverController observerController;
    late Widget widget;

    tearDown(() {
      scrollController.dispose();
    });

    resetAll() {
      scrollController = ScrollController();
      observerController = SliverObserverController(
        controller: scrollController,
      );
      widget = _buildScrollView(
        scrollController: scrollController,
      );
      widget = SliverViewObserver(
        sliverContexts: () => [
          if (_sliverListCtx != null) _sliverListCtx!,
          if (_sliverGridCtx != null) _sliverGridCtx!
        ],
        child: widget,
        controller: observerController,
      );
    }

    testWidgets(
      'Check observeAllResult',
      (tester) async {
        resetAll();
        await tester.pumpWidget(widget);
        var result = await observerController.dispatchOnceObserve(
          sliverContext: _sliverListCtx!,
        );
        expect(result.isSuccess, isFalse);

        result = await observerController.dispatchOnceObserve(
          sliverContext: _sliverListCtx!,
          isDependObserveCallback: false,
        );
        expect(result.isSuccess, isTrue);
        expect(result.observeAllResult[_sliverListCtx], isNotNull);
        expect(
          result.observeAllResult[_sliverListCtx]?.displayingChildIndexList ??
              [],
          isNotEmpty,
        );
        expect(result.observeAllResult[_sliverGridCtx], isNotNull);

        result = await observerController.dispatchOnceObserve(
          sliverContext: _sliverListCtx!,
          isDependObserveCallback: false,
        );
        expect(result.isSuccess, isTrue);
        expect(
          result.observeAllResult[_sliverListCtx]?.displayingChildIndexList ??
              [],
          isEmpty,
        );

        result = await observerController.dispatchOnceObserve(
          sliverContext: _sliverListCtx!,
          isDependObserveCallback: false,
          isForce: true,
        );
        expect(result.isSuccess, isTrue);
        expect(
          result.observeAllResult[_sliverListCtx]?.displayingChildIndexList ??
              [],
          isNotEmpty,
        );
      },
    );

    testWidgets(
      'Check observeViewportResultModel',
      (tester) async {
        resetAll();
        await tester.pumpWidget(widget);
        var result = await observerController.dispatchOnceObserve(
          sliverContext: _sliverListCtx!,
        );
        expect(result.isSuccess, isFalse);
        result = await observerController.dispatchOnceObserve(
          sliverContext: _sliverListCtx!,
          isDependObserveCallback: false,
        );
        expect(result.isSuccess, isTrue);
        expect(
          result.observeViewportResultModel?.firstChild.sliverContext,
          _sliverListCtx,
        );
        expect(
          result.observeViewportResultModel?.displayingChildModelList ?? [],
          isNotEmpty,
        );
        result = await observerController.dispatchOnceObserve(
          sliverContext: _sliverListCtx!,
          isDependObserveCallback: false,
        );
        expect(result.isSuccess, isTrue);
        expect(
          result.observeViewportResultModel?.displayingChildModelList ?? [],
          isEmpty,
        );
        result = await observerController.dispatchOnceObserve(
          sliverContext: _sliverListCtx!,
          isDependObserveCallback: false,
          isForce: true,
        );
        expect(result.isSuccess, isTrue);
        expect(
          result.observeViewportResultModel?.displayingChildModelList ?? [],
          isNotEmpty,
        );

        expect(_sliverGridCtx, isNotNull);
        observerController.jumpTo(
          index: 0,
          sliverContext: _sliverGridCtx,
        );
        await tester.pumpAndSettle();
        await tester.pump(observerController.observeIntervalForScrolling);
        result = await observerController.dispatchOnceObserve(
          sliverContext: _sliverGridCtx!,
          isDependObserveCallback: false,
        );
        expect(result.isSuccess, isTrue);
        expect(
          result.observeViewportResultModel?.firstChild.sliverContext,
          _sliverGridCtx,
        );
      },
    );
  });

  group(
    'NestedScrollView',
    () {
      late ScrollController outerScrollController;
      ScrollController? bodyScrollController;
      late SliverObserverController observerController;
      late Widget widget;
      BuildContext? _sliverHeaderListCtx;
      BuildContext? _sliverHeaderGridCtx;
      BuildContext? _sliverBodyListCtx;
      BuildContext? _sliverBodyGridCtx;
      GlobalKey appBarKey = GlobalKey();
      GlobalKey nestedScrollViewKey = GlobalKey();
      NestedScrollUtil? nestedScrollUtil;
      Map<BuildContext, ObserveModel> resultMap = {};

      Widget _buildSliverGridView() {
        return SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10.0,
            crossAxisSpacing: 10.0,
            childAspectRatio: 2.0,
          ),
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              if (_sliverBodyGridCtx != context) {
                _sliverBodyGridCtx = context;
                nestedScrollUtil?.bodySliverContexts.add(context);
              }
              return Container(
                color: Colors.green,
                child: Center(
                  child: Text('index -- $index'),
                ),
              );
            },
            childCount: 150,
          ),
        );
      }

      Widget _buildSliverListView() {
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (ctx, index) {
              if (_sliverBodyListCtx != ctx) {
                _sliverBodyListCtx = ctx;
                nestedScrollUtil?.bodySliverContexts.add(ctx);
              }
              return Container(
                height: (index % 2 == 0) ? 80 : 50,
                color: Colors.red,
                child: Center(
                  child: Text(
                    "index -- $index",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              );
            },
            childCount: 30,
          ),
        );
      }

      Widget _buildNestedScrollView() {
        return NestedScrollView(
          key: nestedScrollViewKey,
          controller: outerScrollController,
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                key: appBarKey,
                title: const Text("NestedScrollView"),
                pinned: true,
                forceElevated: innerBoxIsScrolled,
              ),
              SliverFixedExtentList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, index) {
                    if (_sliverHeaderListCtx != ctx) {
                      _sliverHeaderListCtx = ctx;
                      nestedScrollUtil?.headerSliverContexts.add(ctx);
                    }
                    return ListTile(
                      leading: Text("Item $index"),
                    );
                  },
                  childCount: 5,
                ),
                itemExtent: 50,
              ),
              SliverGrid.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10.0,
                  crossAxisSpacing: 10.0,
                  childAspectRatio: 2.0,
                ),
                itemBuilder: (context, index) {
                  if (_sliverHeaderGridCtx != context) {
                    _sliverHeaderGridCtx = context;
                    nestedScrollUtil?.headerSliverContexts.add(context);
                  }
                  return Text("Item $index");
                },
                itemCount: 10,
              ),
            ];
          },
          body: Builder(builder: (context) {
            final innerScrollController = PrimaryScrollController.of(context);
            if (bodyScrollController != innerScrollController) {
              bodyScrollController = innerScrollController;
              nestedScrollUtil?.bodyScrollController = innerScrollController;
              nestedScrollUtil?.outerScrollController = outerScrollController;
            }
            return CustomScrollView(
              slivers: [
                _buildSliverListView(),
                _buildSliverGridView(),
              ],
            );
          }),
        );
      }

      Widget resetAll() {
        resultMap = {};
        nestedScrollUtil = NestedScrollUtil();
        outerScrollController = ScrollController();
        bodyScrollController = null;
        observerController = SliverObserverController(
          controller: outerScrollController,
        );

        widget = _buildNestedScrollView();

        widget = SliverViewObserver(
          controller: observerController,
          child: widget,
          sliverContexts: () {
            return [
              if (_sliverHeaderListCtx != null) _sliverHeaderListCtx!,
              if (_sliverHeaderGridCtx != null) _sliverHeaderGridCtx!,
              if (_sliverBodyListCtx != null) _sliverBodyListCtx!,
              if (_sliverBodyGridCtx != null) _sliverBodyGridCtx!,
            ];
          },
          customOverlap: (sliverContext) {
            return nestedScrollUtil?.calcOverlap(
              nestedScrollViewKey: nestedScrollViewKey,
              sliverContext: sliverContext,
            );
          },
          onObserveAll: (result) {
            resultMap = result;
          },
        );
        widget = MaterialApp(
          home: Material(child: widget),
        );
        return widget;
      }

      tearDown(() {
        outerScrollController.dispose();
        _sliverHeaderListCtx = null;
        _sliverHeaderGridCtx = null;
        _sliverBodyListCtx = null;
        _sliverBodyGridCtx = null;
      });

      testWidgets(
        'Scroll to index',
        (tester) async {
          resetAll();
          await tester.pumpWidget(widget);

          observerController.controller = outerScrollController;
          nestedScrollUtil?.jumpTo(
            nestedScrollViewKey: nestedScrollViewKey,
            observerController: observerController,
            sliverContext: _sliverHeaderListCtx,
            position: NestedScrollUtilPosition.header,
            index: 1,
            offset: (targetOffset) {
              return calcPersistentHeaderExtent(
                offset: targetOffset,
                widgetKey: appBarKey,
              );
            },
          );
          await tester.pumpAndSettle();
          await tester.pump(observerController.observeIntervalForScrolling);
          var headerListObservationResult =
              (resultMap[_sliverHeaderListCtx] as ListViewObserveModel);
          expect(headerListObservationResult.firstChild?.index, 1);

          observerController.controller = outerScrollController;
          nestedScrollUtil?.animateTo(
            nestedScrollViewKey: nestedScrollViewKey,
            observerController: observerController,
            sliverContext: _sliverHeaderListCtx,
            position: NestedScrollUtilPosition.header,
            index: 2,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            offset: (targetOffset) {
              return calcPersistentHeaderExtent(
                offset: targetOffset,
                widgetKey: appBarKey,
              );
            },
          );
          await tester.pumpAndSettle();
          await tester.pump(observerController.observeIntervalForScrolling);
          headerListObservationResult =
              (resultMap[_sliverHeaderListCtx] as ListViewObserveModel);
          expect(headerListObservationResult.firstChild?.index, 2);

          expect(bodyScrollController != null, true);
          nestedScrollUtil?.jumpTo(
            nestedScrollViewKey: nestedScrollViewKey,
            observerController: observerController,
            sliverContext: _sliverBodyListCtx,
            position: NestedScrollUtilPosition.body,
            index: 5,
            offset: (targetOffset) {
              return calcPersistentHeaderExtent(
                offset: targetOffset,
                widgetKey: appBarKey,
              );
            },
          );
          await tester.pumpAndSettle();
          await tester.pump(observerController.observeIntervalForScrolling);
          var bodyListObservationResult =
              (resultMap[_sliverBodyListCtx] as ListViewObserveModel);
          expect(bodyListObservationResult.firstChild?.index, 5);

          nestedScrollUtil?.animateTo(
            nestedScrollViewKey: nestedScrollViewKey,
            observerController: observerController,
            sliverContext: _sliverBodyListCtx,
            position: NestedScrollUtilPosition.body,
            index: 20,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            offset: (targetOffset) {
              return calcPersistentHeaderExtent(
                offset: targetOffset,
                widgetKey: appBarKey,
              );
            },
          );
          await tester.pumpAndSettle();
          await tester.pump(observerController.observeIntervalForScrolling);
          bodyListObservationResult =
              (resultMap[_sliverBodyListCtx] as ListViewObserveModel);
          expect(bodyListObservationResult.firstChild?.index, 20);

          nestedScrollUtil?.jumpTo(
            nestedScrollViewKey: nestedScrollViewKey,
            observerController: observerController,
            sliverContext: _sliverBodyGridCtx,
            position: NestedScrollUtilPosition.body,
            index: 10,
            offset: (targetOffset) {
              return calcPersistentHeaderExtent(
                offset: targetOffset,
                widgetKey: appBarKey,
              );
            },
          );
          await tester.pumpAndSettle();
          await tester.pump(observerController.observeIntervalForScrolling);
          var bodyGridObservationResult =
              (resultMap[_sliverBodyGridCtx] as GridViewObserveModel);
          var bodyGridFirstGroupChildIndexList = bodyGridObservationResult
              .firstGroupChildList
              .map((e) => e.index)
              .toList();
          expect(bodyGridFirstGroupChildIndexList.contains(10), true);

          nestedScrollUtil?.animateTo(
            nestedScrollViewKey: nestedScrollViewKey,
            observerController: observerController,
            sliverContext: _sliverBodyGridCtx,
            position: NestedScrollUtilPosition.body,
            index: 20,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            offset: (targetOffset) {
              return calcPersistentHeaderExtent(
                offset: targetOffset,
                widgetKey: appBarKey,
              );
            },
          );
          await tester.pumpAndSettle();
          await tester.pump(observerController.observeIntervalForScrolling);
          bodyGridObservationResult =
              (resultMap[_sliverBodyGridCtx] as GridViewObserveModel);
          bodyGridFirstGroupChildIndexList = bodyGridObservationResult
              .firstGroupChildList
              .map((e) => e.index)
              .toList();
          expect(bodyGridFirstGroupChildIndexList.contains(20), true);
        },
      );

      testWidgets(
        'Check method reset of NestedScrollUtil',
        (tester) async {
          resetAll();
          await tester.pumpWidget(widget);
          expect(nestedScrollUtil?.headerSliverContexts.length, 2);
          expect(nestedScrollUtil?.bodySliverContexts.length, 2);
          expect(nestedScrollUtil?.remainingSliverContext == null, true);
          expect(nestedScrollUtil?.remainingSliverRenderObj == null, true);
          nestedScrollUtil?.fetchRemainingSliverContext(
            nestedScrollViewKey: nestedScrollViewKey,
          );
          expect(nestedScrollUtil?.remainingSliverContext != null, true);
          expect(nestedScrollUtil?.remainingSliverRenderObj != null, true);
          nestedScrollUtil?.reset();
          expect(nestedScrollUtil?.headerSliverContexts.length, 0);
          expect(nestedScrollUtil?.bodySliverContexts.length, 0);
          expect(nestedScrollUtil?.remainingSliverContext, null);
          expect(nestedScrollUtil?.remainingSliverRenderObj, null);
        },
      );

      testWidgets(
        'Check the observed data when the sliver in the header is not visible',
        (tester) async {
          resetAll();
          await tester.pumpWidget(widget);
          await observerController.dispatchOnceObserve(
            sliverContext: _sliverHeaderListCtx!,
          );
          var headerListObservationResult =
              (resultMap[_sliverHeaderListCtx] as ListViewObserveModel);
          expect(
            headerListObservationResult.displayingChildIndexList,
            isNotEmpty,
          );

          nestedScrollUtil?.jumpTo(
            nestedScrollViewKey: nestedScrollViewKey,
            observerController: observerController,
            sliverContext: _sliverHeaderGridCtx,
            position: NestedScrollUtilPosition.header,
            index: 0,
            offset: (targetOffset) {
              return calcPersistentHeaderExtent(
                offset: targetOffset,
                widgetKey: appBarKey,
              );
            },
          );
          await tester.pumpAndSettle();
          await tester.pump(observerController.observeIntervalForScrolling);

          headerListObservationResult =
              (resultMap[_sliverHeaderListCtx] as ListViewObserveModel);
          expect(
            headerListObservationResult.displayingChildIndexList,
            isEmpty,
          );

          var headerGridObservationResult =
              (resultMap[_sliverHeaderGridCtx] as GridViewObserveModel);
          expect(
            headerGridObservationResult.firstGroupChildList.first.index,
            0,
          );

          nestedScrollUtil?.jumpTo(
            nestedScrollViewKey: nestedScrollViewKey,
            observerController: observerController,
            sliverContext: _sliverBodyListCtx,
            position: NestedScrollUtilPosition.body,
            index: 0,
            offset: (targetOffset) {
              return calcPersistentHeaderExtent(
                offset: targetOffset,
                widgetKey: appBarKey,
              );
            },
          );
          await tester.pumpAndSettle();
          await tester.pump(observerController.observeIntervalForScrolling);

          var bodyListObservationResult =
              (resultMap[_sliverBodyListCtx] as ListViewObserveModel);
          expect(
            bodyListObservationResult.firstChild?.index,
            0,
          );

          headerGridObservationResult =
              (resultMap[_sliverHeaderGridCtx] as GridViewObserveModel);
          expect(
            headerGridObservationResult.displayingChildIndexList,
            isEmpty,
          );
        },
      );
    },
  );

  group(
    'Configure center in CustomScrollView',
    () {
      late Widget widget;
      BuildContext? _sliverListCtx1;
      BuildContext? _sliverListCtx2;
      BuildContext? _sliverListCtx3;
      BuildContext? _sliverListCtx4;
      final _centerKey = GlobalKey();
      ScrollController scrollController = ScrollController();
      late SliverObserverController observerController;
      Map<BuildContext, ObserveModel> resultMap = {};

      Widget _buildSliverListView({
        required Color color,
        Function(BuildContext)? onBuild,
      }) {
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (ctx, index) {
              onBuild?.call(ctx);
              final int itemIndex = index ~/ 2;
              return Container(
                height: (itemIndex % 2 == 0) ? 80 : 50,
                color: color,
                child: Center(
                  child: Text(
                    "index -- $index",
                  ),
                ),
              );
            },
            childCount: 100,
          ),
        );
      }

      Widget _buildScrollView({
        required double anchor,
      }) {
        return CustomScrollView(
          center: _centerKey,
          anchor: anchor,
          controller: scrollController,
          slivers: [
            _buildSliverListView(
              color: Colors.redAccent,
              onBuild: (ctx) {
                _sliverListCtx1 = ctx;
              },
            ),
            _buildSliverListView(
              color: Colors.blueGrey,
              onBuild: (ctx) {
                _sliverListCtx2 = ctx;
              },
            ),
            SliverPadding(padding: EdgeInsets.zero, key: _centerKey),
            _buildSliverListView(
              color: Colors.teal,
              onBuild: (ctx) {
                _sliverListCtx3 = ctx;
              },
            ),
            _buildSliverListView(
              color: Colors.purple,
              onBuild: (ctx) {
                _sliverListCtx4 = ctx;
              },
            ),
          ],
        );
      }

      Widget resetAll({
        required double anchor,
      }) {
        resultMap = {};
        scrollController = ScrollController();
        observerController = SliverObserverController(
          controller: scrollController,
        );

        widget = _buildScrollView(anchor: anchor);

        widget = SliverViewObserver(
          controller: observerController,
          child: widget,
          sliverContexts: () {
            return [
              if (_sliverListCtx1 != null) _sliverListCtx1!,
              if (_sliverListCtx2 != null) _sliverListCtx2!,
              if (_sliverListCtx3 != null) _sliverListCtx3!,
              if (_sliverListCtx4 != null) _sliverListCtx4!,
            ];
          },
          onObserveAll: (result) {
            resultMap = result;
          },
        );
        widget = MaterialApp(
          home: Material(child: widget),
        );
        return widget;
      }

      tearDown(() {
        scrollController.dispose();
        _sliverListCtx1 = null;
        _sliverListCtx2 = null;
        _sliverListCtx3 = null;
        _sliverListCtx4 = null;
      });

      testWidgets('Check isForwardGrowthDirection', (tester) async {
        resetAll(anchor: 0.5);
        await tester.pumpWidget(widget);

        final _sliverListObj1 = ObserverUtils.findRenderObject(_sliverListCtx1);
        expect(_sliverListObj1 is RenderSliverMultiBoxAdaptor, true);
        _sliverListObj1 as RenderSliverMultiBoxAdaptor;
        expect(_sliverListObj1.isForwardGrowthDirection, false);

        final _sliverListObj2 = ObserverUtils.findRenderObject(_sliverListCtx2);
        expect(_sliverListObj2 is RenderSliverMultiBoxAdaptor, true);
        _sliverListObj2 as RenderSliverMultiBoxAdaptor;
        expect(_sliverListObj2.isForwardGrowthDirection, false);

        final _sliverListObj3 = ObserverUtils.findRenderObject(_sliverListCtx3);
        expect(_sliverListObj3 is RenderSliverMultiBoxAdaptor, true);
        _sliverListObj3 as RenderSliverMultiBoxAdaptor;
        expect(_sliverListObj3.isForwardGrowthDirection, true);

        final _sliverListObj4 = ObserverUtils.findRenderObject(_sliverListCtx4);
        expect(_sliverListObj4 is RenderSliverMultiBoxAdaptor, true);
        _sliverListObj4 as RenderSliverMultiBoxAdaptor;
        expect(_sliverListObj4.isForwardGrowthDirection, true);
      });

      testWidgets('Check viewportExtremeScrollExtent and rectify',
          (tester) async {
        resetAll(anchor: 0.5);
        await tester.pumpWidget(widget);

        final _sliverListObj1 = ObserverUtils.findRenderObject(_sliverListCtx1);
        expect(_sliverListObj1 != null, true);
        expect(_sliverListObj1 is RenderSliverMultiBoxAdaptor, true);
        _sliverListObj1 as RenderSliverMultiBoxAdaptor;
        var extremeScrollExtent =
            observerController.viewportExtremeScrollExtent(
          viewport: ObserverUtils.findViewport(_sliverListObj1)!,
          obj: _sliverListObj1,
        );
        expect(extremeScrollExtent <= 0, true);
        expect(extremeScrollExtent.rectify(_sliverListObj1) >= 0, true);

        final _sliverListObj2 = ObserverUtils.findRenderObject(_sliverListCtx2);
        expect(_sliverListObj2 != null, true);
        expect(_sliverListObj2 is RenderSliverMultiBoxAdaptor, true);
        _sliverListObj2 as RenderSliverMultiBoxAdaptor;
        extremeScrollExtent = observerController.viewportExtremeScrollExtent(
          viewport: ObserverUtils.findViewport(_sliverListObj2)!,
          obj: _sliverListObj2,
        );
        expect(extremeScrollExtent <= 0, true);
        expect(extremeScrollExtent.rectify(_sliverListObj2) >= 0, true);

        final _sliverListObj3 = ObserverUtils.findRenderObject(_sliverListCtx3);
        expect(_sliverListObj3 != null, true);
        expect(_sliverListObj3 is RenderSliverMultiBoxAdaptor, true);
        _sliverListObj3 as RenderSliverMultiBoxAdaptor;
        extremeScrollExtent = observerController.viewportExtremeScrollExtent(
          viewport: ObserverUtils.findViewport(_sliverListObj3)!,
          obj: _sliverListObj3,
        );
        expect(extremeScrollExtent >= 0, true);
        expect(extremeScrollExtent.rectify(_sliverListObj3) >= 0, true);

        final _sliverListObj4 = ObserverUtils.findRenderObject(_sliverListCtx4);
        expect(_sliverListObj4 != null, true);
        expect(_sliverListObj4 is RenderSliverMultiBoxAdaptor, true);
        _sliverListObj4 as RenderSliverMultiBoxAdaptor;
        extremeScrollExtent = observerController.viewportExtremeScrollExtent(
          viewport: ObserverUtils.findViewport(_sliverListObj4)!,
          obj: _sliverListObj4,
        );
        expect(extremeScrollExtent >= 0, true);
        expect(extremeScrollExtent.rectify(_sliverListObj4) >= 0, true);
      });

      testWidgets(
        'Scroll to index with anchor 1.0',
        (tester) async {
          resetAll(anchor: 1.0);
          await tester.pumpWidget(widget);

          observerController.jumpTo(
            index: 1,
            sliverContext: _sliverListCtx1,
          );
          await tester.pumpAndSettle();
          await tester.pump(observerController.observeIntervalForScrolling);
          final sliverList1ObservationResult =
              (resultMap[_sliverListCtx1] as ListViewObserveModel);
          expect(sliverList1ObservationResult.firstChild?.index, 1);

          observerController.jumpTo(
            index: 5,
            sliverContext: _sliverListCtx2,
          );
          await tester.pumpAndSettle();
          await tester.pump(observerController.observeIntervalForScrolling);
          final sliverList2ObservationResult =
              (resultMap[_sliverListCtx2] as ListViewObserveModel);
          expect(sliverList2ObservationResult.firstChild?.index, 5);

          observerController.jumpTo(
            index: 10,
            sliverContext: _sliverListCtx3,
            alignment: 1,
          );
          await tester.pumpAndSettle();
          await tester.pump(observerController.observeIntervalForScrolling);
          final sliverList3ObservationResult =
              (resultMap[_sliverListCtx3] as ListViewObserveModel);
          expect(
            sliverList3ObservationResult.displayingChildModelList.last.index,
            10,
          );

          observerController.jumpTo(
            index: 8,
            sliverContext: _sliverListCtx4,
            alignment: 1,
          );
          await tester.pumpAndSettle();
          await tester.pump(observerController.observeIntervalForScrolling);
          final sliverList4ObservationResult =
              (resultMap[_sliverListCtx4] as ListViewObserveModel);
          expect(
            sliverList4ObservationResult.displayingChildModelList.last.index,
            8,
          );
        },
      );

      testWidgets(
        'Scroll to index with anchor 0.0',
        (tester) async {
          resetAll(anchor: 0.0);
          await tester.pumpWidget(widget);

          observerController.jumpTo(
            index: 1,
            sliverContext: _sliverListCtx1,
            alignment: 1,
          );
          await tester.pumpAndSettle();
          await tester.pump(observerController.observeIntervalForScrolling);
          final sliverList1ObservationResult =
              (resultMap[_sliverListCtx1] as ListViewObserveModel);
          expect(
            sliverList1ObservationResult.displayingChildModelList.last.index,
            1,
          );

          observerController.jumpTo(
            index: 5,
            sliverContext: _sliverListCtx2,
            alignment: 1,
          );
          await tester.pumpAndSettle();
          await tester.pump(observerController.observeIntervalForScrolling);
          final sliverList2ObservationResult =
              (resultMap[_sliverListCtx2] as ListViewObserveModel);
          expect(
            sliverList2ObservationResult.displayingChildModelList.last.index,
            5,
          );

          observerController.jumpTo(
            index: 10,
            sliverContext: _sliverListCtx3,
          );
          await tester.pumpAndSettle();
          await tester.pump(observerController.observeIntervalForScrolling);
          final sliverList3ObservationResult =
              (resultMap[_sliverListCtx3] as ListViewObserveModel);
          expect(sliverList3ObservationResult.firstChild?.index, 10);

          observerController.jumpTo(
            index: 8,
            sliverContext: _sliverListCtx4,
          );
          await tester.pumpAndSettle();
          await tester.pump(observerController.observeIntervalForScrolling);
          final sliverList4ObservationResult =
              (resultMap[_sliverListCtx4] as ListViewObserveModel);
          expect(sliverList4ObservationResult.firstChild?.index, 8);
        },
      );
    },
  );

  group('ObserverListener', () {
    late String tag1;
    late String tag2;
    late GlobalKey key1;
    late GlobalKey key2;
    late ScrollController scrollController;
    late SliverObserverController observerController1;
    late SliverObserverController observerController2;
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
        observerController1 = SliverObserverController(
          controller: scrollController,
        );
        observerController2 = SliverObserverController(
          controller: scrollController,
        );
      }
      widget = _buildScrollView(
        scrollController: scrollController,
        listItemBuilder: (context, index) {
          if (index == 3) {
            return const SizedBox(
              height: 50,
              child: Center(
                child: Icon(Icons.list),
              ),
            );
          }
          return Container(height: 50);
        },
        gridItemBuilder: (context, index) {
          if (index == 3) {
            return const Center(
              child: Icon(Icons.grid_view),
            );
          }
          return Container();
        },
      );
      widget = SliverViewObserver(
        key: key2,
        tag: tag2,
        sliverContexts: () => [
          if (_sliverListCtx != null) _sliverListCtx!,
          if (_sliverGridCtx != null) _sliverGridCtx!
        ],
        child: widget,
        controller: observerController2,
      );
      widget = SliverViewObserver(
        key: key1,
        tag: tag1,
        sliverContexts: () => [
          if (_sliverListCtx != null) _sliverListCtx!,
          if (_sliverGridCtx != null) _sliverGridCtx!
        ],
        child: widget,
        controller: observerController1,
      );
    }

    testWidgets('Change tag', (tester) async {
      resetAll();
      await tester.pumpWidget(widget);

      final listItemFinder = find.byIcon(Icons.list);

      ObserverWidgetTagManager? tagManager = ObserverWidgetTagManager.maybeOf(
        tester.element(listItemFinder),
      );
      expect(tagManager, isNotNull);

      Map<String, BuildContext> tagMap = Map.from(tagManager?.tagMap ?? {});
      Set<String> tags = {tag1, tag2};
      expect(tagMap.keys.toSet(), tags);

      resetAll(isResetTag: true);
      await tester.pumpWidget(widget);

      tagManager = ObserverWidgetTagManager.maybeOf(
        tester.element(listItemFinder),
      );
      tagMap = Map.from(tagManager?.tagMap ?? {});
      Set<String> newTags = {tag1, tag2};
      expect(tags != newTags, isTrue);
      expect(tagMap.keys.toSet(), newTags);
    });

    testWidgets('of', (tester) async {
      resetAll();
      await tester.pumpWidget(widget);

      final listItemFinder = find.byIcon(Icons.list);
      final gridItemFinder = find.byIcon(Icons.grid_view);

      ObserveModel? cbResult;
      Map<BuildContext, ObserveModel>? cbAllResult;
      SliverViewportObserveModel? cbObserveViewportResult;
      onObserveCallback(ObserveModel result) {
        cbResult = result;
      }

      onObserveAllCallback(
        Map<BuildContext, ObserveModel> resultMap,
      ) {
        cbAllResult = resultMap;
      }

      onObserveViewportCallback(SliverViewportObserveModel result) {
        cbObserveViewportResult = result;
      }

      final listObserverState = SliverViewObserver.of(
        tester.element(listItemFinder),
      );
      expect(listObserverState, isNotNull);

      final listObserverStateByTag2 = SliverViewObserver.of(
        tester.element(listItemFinder),
        tag: tag2,
      );
      expect(listObserverStateByTag2 == key2.currentState, isTrue);
      expect(listObserverStateByTag2 == listObserverState, isTrue);

      final listObserverStateByTag1 = SliverViewObserver.of(
        tester.element(listItemFinder),
        tag: tag1,
      );
      expect(listObserverStateByTag1 == key1.currentState, isTrue);
      expect(listObserverStateByTag1 == listObserverState, isFalse);

      listObserverState.addListener(
        onObserve: onObserveCallback,
        onObserveAll: onObserveAllCallback,
        onObserveViewport: onObserveViewportCallback,
      );
      expect(listObserverState.innerListeners?.length, 1);

      ScrollViewOnceObserveNotificationResult? result =
          await observerController2.dispatchOnceObserve(
        sliverContext: _sliverListCtx!,
        isDependObserveCallback: false,
      );
      expect(result.observeResult, cbResult);
      expect(result.observeAllResult, cbAllResult);
      expect(result.observeViewportResultModel, cbObserveViewportResult);

      listObserverState.removeListener(
        onObserve: onObserveCallback,
        onObserveAll: onObserveAllCallback,
        onObserveViewport: onObserveViewportCallback,
      );
      expect(listObserverState.innerListeners?.length, 0);

      observerController2.jumpTo(
        index: 0,
        sliverContext: _sliverGridCtx,
      );
      await tester.pumpAndSettle();
      await tester.pump(observerController2.observeIntervalForScrolling);
      cbResult = null;
      cbAllResult = null;
      cbObserveViewportResult = null;

      final gridObserverState = SliverViewObserver.of(
        tester.element(gridItemFinder),
      );
      expect(gridObserverState, isNotNull);
      expect(gridObserverState == listObserverState, isTrue);

      final gridObserverStateByTag2 = SliverViewObserver.of(
        tester.element(gridItemFinder),
        tag: tag2,
      );
      expect(gridObserverStateByTag2 == key2.currentState, isTrue);
      expect(gridObserverStateByTag2 == listObserverState, isTrue);

      final gridObserverStateByTag1 = SliverViewObserver.of(
        tester.element(gridItemFinder),
        tag: tag1,
      );
      expect(gridObserverStateByTag1 == key1.currentState, isTrue);
      expect(gridObserverStateByTag1 == listObserverState, isFalse);

      gridObserverState.addListener(
        onObserve: onObserveCallback,
        onObserveAll: onObserveAllCallback,
        onObserveViewport: onObserveViewportCallback,
      );
      expect(gridObserverState.innerListeners?.length, 1);

      result = await observerController2.dispatchOnceObserve(
        sliverContext: _sliverListCtx!,
      );
      expect(result.observeResult, cbResult);
      expect(result.observeAllResult, cbAllResult);
      expect(result.observeViewportResultModel, cbObserveViewportResult);

      gridObserverState.removeListener(
        onObserve: onObserveCallback,
        onObserveAll: onObserveAllCallback,
        onObserveViewport: onObserveViewportCallback,
      );
      expect(gridObserverState.innerListeners?.length, 0);
    });

    testWidgets('maybeOf', (tester) async {
      resetAll();
      await tester.pumpWidget(widget);

      final listItemFinder = find.byIcon(Icons.list);
      final gridItemFinder = find.byIcon(Icons.grid_view);

      MixViewObserverState? observerState = SliverViewObserver.maybeOf(
        tester.element(find.byKey(key1)),
      );
      expect(observerState, isNull);

      ObserveModel? cbResult;
      Map<BuildContext, ObserveModel>? cbAllResult;
      SliverViewportObserveModel? cbObserveViewportResult;
      onObserveCallback(ObserveModel result) {
        cbResult = result;
      }

      onObserveAllCallback(
        Map<BuildContext, ObserveModel> resultMap,
      ) {
        cbAllResult = resultMap;
      }

      onObserveViewportCallback(SliverViewportObserveModel result) {
        cbObserveViewportResult = result;
      }

      MixViewObserverState? listObserverState = SliverViewObserver.maybeOf(
        tester.element(listItemFinder),
      );
      expect(listObserverState, isNotNull);

      final listObserverStateByTag2 = SliverViewObserver.maybeOf(
        tester.element(listItemFinder),
        tag: tag2,
      );
      expect(listObserverStateByTag2 == key2.currentState, isTrue);
      expect(listObserverStateByTag2 == listObserverState, isTrue);

      final listObserverStateByTag1 = SliverViewObserver.maybeOf(
        tester.element(listItemFinder),
        tag: tag1,
      );
      expect(listObserverStateByTag1 == key1.currentState, isTrue);
      expect(listObserverStateByTag1 == listObserverState, isFalse);

      listObserverState?.addListener(
        onObserve: onObserveCallback,
        onObserveAll: onObserveAllCallback,
        onObserveViewport: onObserveViewportCallback,
      );
      expect(listObserverState?.innerSliverListeners?.length, 1);
      expect(listObserverState?.innerListeners?.length, 1);

      ScrollViewOnceObserveNotificationResult? result =
          await observerController2.dispatchOnceObserve(
        sliverContext: _sliverListCtx!,
        isDependObserveCallback: false,
      );
      expect(result.observeResult, cbResult);
      expect(result.observeAllResult, cbAllResult);
      expect(result.observeViewportResultModel, cbObserveViewportResult);

      listObserverState?.removeListener(
        onObserve: onObserveCallback,
        onObserveAll: onObserveAllCallback,
        onObserveViewport: onObserveViewportCallback,
      );
      expect(listObserverState?.innerSliverListeners?.length, 0);
      expect(listObserverState?.innerListeners?.length, 0);

      observerController2.jumpTo(
        index: 0,
        sliverContext: _sliverGridCtx,
      );
      await tester.pumpAndSettle();
      await tester.pump(observerController2.observeIntervalForScrolling);
      cbResult = null;
      cbAllResult = null;
      cbObserveViewportResult = null;

      MixViewObserverState? gridObserverState = SliverViewObserver.maybeOf(
        tester.element(find.byIcon(Icons.grid_view)),
      );
      expect(gridObserverState, isNotNull);
      final gridObserverStateByTag2 = SliverViewObserver.maybeOf(
        tester.element(gridItemFinder),
        tag: tag2,
      );

      expect(gridObserverStateByTag2 == key2.currentState, isTrue);
      expect(gridObserverStateByTag2 == gridObserverState, isTrue);

      final gridObserverStateByTag1 = SliverViewObserver.maybeOf(
        tester.element(gridItemFinder),
        tag: tag1,
      );
      expect(gridObserverStateByTag1 == key1.currentState, isTrue);
      expect(gridObserverStateByTag1 == gridObserverState, isFalse);

      gridObserverState?.addListener(
        onObserve: onObserveCallback,
        onObserveAll: onObserveAllCallback,
        onObserveViewport: onObserveViewportCallback,
      );
      expect(gridObserverState?.innerSliverListeners?.length, 1);
      expect(gridObserverState?.innerListeners?.length, 1);

      result = await observerController2.dispatchOnceObserve(
        sliverContext: _sliverListCtx!,
        isDependObserveCallback: false,
      );
      expect(result.observeResult, cbResult);
      expect(result.observeAllResult, cbAllResult);
      expect(result.observeViewportResultModel, cbObserveViewportResult);

      gridObserverState?.removeListener(
        onObserve: onObserveCallback,
        onObserveAll: onObserveAllCallback,
        onObserveViewport: onObserveViewportCallback,
      );
      expect(gridObserverState?.innerSliverListeners?.length, 0);
      expect(gridObserverState?.innerListeners?.length, 0);
    });
  });
}
