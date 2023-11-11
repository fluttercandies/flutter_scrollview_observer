import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scrollview_observer/scrollview_observer.dart';

void main() {
  GlobalKey sliverListKey = GlobalKey();
  GlobalKey sliverGridKey = GlobalKey();
  BuildContext? _sliverListCtx;
  BuildContext? _sliverGridCtx;

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
    return Directionality(
      textDirection: TextDirection.ltr,
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
}
