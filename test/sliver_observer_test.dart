import 'package:flutter/material.dart';
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
    expect(isCalledOnObserve, false);

    observerController.isForbidObserveCallback = false;
    observerController.jumpTo(index: 20, sliverContext: _sliverListCtx);
    await tester.pumpAndSettle();
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
    expect(isCalledOnObserveViewport, false);

    observerController.isForbidObserveViewportCallback = false;
    observerController.jumpTo(index: 20, sliverContext: _sliverGridCtx);
    await tester.pumpAndSettle();
    expect(isCalledOnObserveViewport, true);

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
          observerController.jumpTo(
            index: 1,
            sliverContext: _sliverHeaderListCtx,
            offset: (targetOffset) {
              return calcPersistentHeaderExtent(
                offset: targetOffset,
                widgetKey: appBarKey,
              );
            },
          );
          await tester.pumpAndSettle();
          final headerListObservationResult =
              (resultMap[_sliverHeaderListCtx] as ListViewObserveModel);
          expect(headerListObservationResult.firstChild?.index, 1);

          expect(bodyScrollController != null, true);
          observerController.controller = bodyScrollController;
          observerController.jumpTo(
            index: 5,
            sliverContext: _sliverBodyListCtx,
            offset: (targetOffset) {
              return calcPersistentHeaderExtent(
                offset: targetOffset,
                widgetKey: appBarKey,
              );
            },
          );
          await tester.pumpAndSettle();
          final bodyListObservationResult =
              (resultMap[_sliverBodyListCtx] as ListViewObserveModel);
          expect(bodyListObservationResult.firstChild?.index, 5);

          observerController.jumpTo(
            index: 10,
            sliverContext: _sliverBodyGridCtx,
            offset: (targetOffset) {
              return calcPersistentHeaderExtent(
                offset: targetOffset,
                widgetKey: appBarKey,
              );
            },
          );
          await tester.pumpAndSettle();
          final bodyGridObservationResult =
              (resultMap[_sliverBodyGridCtx] as GridViewObserveModel);
          final bodyGridFirstGroupChildIndexList = bodyGridObservationResult
              .firstGroupChildList
              .map((e) => e.index)
              .toList();
          expect(bodyGridFirstGroupChildIndexList.contains(10), true);
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
}
