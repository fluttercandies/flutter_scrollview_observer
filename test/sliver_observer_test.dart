import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scrollview_observer/scrollview_observer.dart';

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

  Widget _buildSliverListView() {
    return SliverList(
      key: sliverListKey,
      delegate: SliverChildBuilderDelegate(
        (ctx, index) {
          _sliverListCtx ??= ctx;
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

  Widget _buildSliverGridView() {
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
  }) {
    return _buildDirectionality(
      child: CustomScrollView(
        controller: scrollController,
        slivers: [
          _buildSliverListView(),
          _buildSliverGridView(),
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
    final observerController =
        SliverObserverController(controller: scrollController);

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
    final observerController =
        SliverObserverController(controller: scrollController);

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
    final observerController =
        SliverObserverController(controller: scrollController)
          ..observeIntervalForScrolling = const Duration(milliseconds: 500);
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
        observerController =
            SliverObserverController(controller: scrollController);

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
          expect(nestedScrollUtil?.headerSliverContexts.length, 1);
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
}
