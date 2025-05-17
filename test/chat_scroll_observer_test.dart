/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/fluttercandies/flutter_scrollview_observer
 * @Date: 2023-11-25 19:04:30
 */
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scrollview_observer/scrollview_observer.dart';

void main() {
  // Regression test for https://github.com/fluttercandies/flutter_scrollview_observer/issues/64.
  testWidgets('Keeping position', (tester) async {
    final scrollController = ScrollController();
    final observerController =
        ListObserverController(controller: scrollController);
    final chatScrollObserver = ChatScrollObserver(observerController)
      ..fixedPositionOffset = -1;

    int receiveScrollNotificationCount = 0;

    Widget widget = ChatListView(
      scrollController: scrollController,
      observerController: observerController,
      chatScrollObserver: chatScrollObserver,
      onReceiveScrollNotification: () {
        receiveScrollNotificationCount += 1;
      },
    );
    await tester.pumpWidget(widget);
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    final result = await observerController.dispatchOnceObserve(
      isForce: true,
      isDependObserveCallback: false,
    );
    expect(result.observeResult?.firstChild?.index, 4);
    expect(receiveScrollNotificationCount, 0);

    scrollController.dispose();
  });

  testWidgets('Keeping position with ChatScrollObserverHandleMode.specified',
      (tester) async {
    GlobalKey<ChatListViewState> key = GlobalKey();
    final scrollController = ScrollController();
    final observerController =
        ListObserverController(controller: scrollController);
    final chatScrollObserver = ChatScrollObserver(observerController)
      ..fixedPositionOffset = -1;
    const firstDisplayingChildIndex = 2;

    Widget widget = ChatListView(
      key: key,
      scrollController: scrollController,
      observerController: observerController,
      chatScrollObserver: chatScrollObserver,
    );
    await tester.pumpWidget(widget);

    updateData({
      int index = 0,
    }) {
      key.currentState?.updateData(
        index: index,
        needSetState: true,
      );
    }

    observerController.jumpTo(index: firstDisplayingChildIndex);
    await tester.pumpAndSettle();
    var result = await observerController.dispatchOnceObserve(
      isDependObserveCallback: false,
      isForce: true,
    );
    expectSync(
      result.observeResult?.firstChild?.index,
      firstDisplayingChildIndex,
    );
    expectSync(result.observeResult?.firstChild?.leadingMarginToViewport, 0);

    // relativeIndexStartFromCacheExtent
    var firstItemModel = observerController.observeFirstItem();
    var firstItemIndex = firstItemModel?.index ?? 0;
    await chatScrollObserver.standby(
      mode: ChatScrollObserverHandleMode.specified,
      refIndexType:
          ChatScrollObserverRefIndexType.relativeIndexStartFromCacheExtent,
      refItemIndex: 1,
      refItemIndexAfterUpdate: 1,
    );
    expect(chatScrollObserver.refItemIndex, firstItemIndex + 1);
    expect(
      chatScrollObserver.refItemIndexAfterUpdate,
      firstItemIndex + 1,
    );
    updateData();
    await tester.pumpAndSettle();
    result = await observerController.dispatchOnceObserve(
      isDependObserveCallback: false,
      isForce: true,
    );
    expectSync(
      result.observeResult?.firstChild?.index,
      firstDisplayingChildIndex,
    );
    expectSync(result.observeResult?.firstChild?.leadingMarginToViewport, 0);

    // relativeIndexStartFromDisplaying
    result = await observerController.dispatchOnceObserve(
      isDependObserveCallback: false,
      isForce: true,
    );
    var currentFirstDisplayingChildIndex =
        result.observeResult?.firstChild?.index ?? 0;
    await chatScrollObserver.standby(
      mode: ChatScrollObserverHandleMode.specified,
      refIndexType:
          ChatScrollObserverRefIndexType.relativeIndexStartFromDisplaying,
      refItemIndex: 1,
      refItemIndexAfterUpdate: 1,
    );
    expect(
      chatScrollObserver.refItemIndex,
      currentFirstDisplayingChildIndex + 1,
    );
    expect(
      chatScrollObserver.refItemIndexAfterUpdate,
      currentFirstDisplayingChildIndex + 1,
    );
    updateData();
    await tester.pumpAndSettle();
    result = await observerController.dispatchOnceObserve(
      isDependObserveCallback: false,
      isForce: true,
    );
    expectSync(
      result.observeResult?.firstChild?.index,
      firstDisplayingChildIndex,
    );
    expectSync(result.observeResult?.firstChild?.leadingMarginToViewport, 0);

    // itemIndex
    await chatScrollObserver.standby(
      mode: ChatScrollObserverHandleMode.specified,
      refIndexType: ChatScrollObserverRefIndexType.itemIndex,
      refItemIndex: firstDisplayingChildIndex,
      refItemIndexAfterUpdate: firstDisplayingChildIndex,
    );
    updateData();
    await tester.pumpAndSettle();
    expect(chatScrollObserver.refItemIndex, firstDisplayingChildIndex);
    expect(
      chatScrollObserver.refItemIndexAfterUpdate,
      firstDisplayingChildIndex,
    );
    result = await observerController.dispatchOnceObserve(
      isDependObserveCallback: false,
      isForce: true,
    );
    expectSync(
      result.observeResult?.firstChild?.index,
      firstDisplayingChildIndex,
    );
    expectSync(result.observeResult?.firstChild?.leadingMarginToViewport, 0);

    scrollController.dispose();
  });

  testWidgets(
      'Keeping position with ChatScrollObserverHandleMode.specified when item changes by itself',
      (tester) async {
    GlobalKey<ChatListViewState> key = GlobalKey();
    final scrollController = ScrollController();
    final observerController = ListObserverController(
      controller: scrollController,
    );
    final chatScrollObserver = ChatScrollObserver(observerController)
      ..fixedPositionOffset = -1;
    const observeItemSelfIndex = 0;

    Widget widget = ChatListView(
      key: key,
      scrollController: scrollController,
      observerController: observerController,
      chatScrollObserver: chatScrollObserver,
      itemBuilder: (context, index) {
        final dataList = key.currentState?.dataList ?? [];
        return Text(
          dataList[index],
          maxLines: 999,
        );
      },
      dataList: ['initData' * 500],
    );
    await tester.pumpWidget(widget);

    void updateData({
      int index = 0,
    }) {
      key.currentState?.updateData(
        index: index,
        needSetState: true,
      );
    }

    await tester.pumpAndSettle();
    var result = await observerController.dispatchOnceObserve(
      isDependObserveCallback: false,
      isForce: true,
    );
    expectSync(
      result.observeResult?.firstChild?.index ?? 0,
      observeItemSelfIndex,
    );
    expectSync(
      result.observeResult?.firstChild?.mainAxisSize,
      greaterThanOrEqualTo(
        result.observeResult?.viewport.paintBounds.height ?? 0,
      ),
    );
    final previousTrailingMarginToViewport =
        result.observeResult?.firstChild?.trailingMarginToViewport;

    // itemIndex
    await chatScrollObserver.standby(
      mode: ChatScrollObserverHandleMode.specified,
      refIndexType: ChatScrollObserverRefIndexType.itemIndex,
      refItemIndex: observeItemSelfIndex,
      refItemIndexAfterUpdate: observeItemSelfIndex,
      customAdjustPositionDelta: (model) {
        return model.newPosition.extentAfter - model.oldPosition.extentAfter;
      },
    );

    updateData();
    await tester.pumpAndSettle();
    result = await observerController.dispatchOnceObserve(
      isDependObserveCallback: false,
      isForce: true,
    );

    expect(chatScrollObserver.refItemIndex, observeItemSelfIndex);
    expect(
      chatScrollObserver.refItemIndexAfterUpdate,
      observeItemSelfIndex,
    );
    result = await observerController.dispatchOnceObserve(
      isDependObserveCallback: false,
      isForce: true,
    );
    expectSync(
      result.observeResult?.firstChild?.index,
      observeItemSelfIndex,
    );
    expectSync(
      result.observeResult?.firstChild?.trailingMarginToViewport,
      previousTrailingMarginToViewport,
    );

    scrollController.dispose();
  });

  testWidgets('Keeping position with customAdjustPositionDelta',
      (tester) async {
    GlobalKey<ChatListViewState> key = GlobalKey();
    final scrollController = ScrollController();
    final observerController = ListObserverController(
      controller: scrollController,
    );
    final chatScrollObserver = ChatScrollObserver(observerController)
      ..fixedPositionOffset = -1;
    Map<int, double> itemHeightMap = {};
    const double expandedItemHeight = 200;
    const double normalItemHeight = 100;

    Widget widget = ChatListView(
      key: key,
      scrollController: scrollController,
      observerController: observerController,
      chatScrollObserver: chatScrollObserver,
      itemBuilder: (context, index) {
        if (itemHeightMap[index] == null) {
          itemHeightMap[index] = normalItemHeight;
        }
        double itemHeight = itemHeightMap[index] ?? normalItemHeight;
        return SizedBox(
          height: itemHeight,
          child: Center(child: Text(index.toString())),
        );
      },
    );
    await tester.pumpWidget(widget);

    Future<void> setState() async {
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pumpAndSettle();
    }

    var result = await observerController.dispatchOnceObserve(
      isForce: true,
      isDependObserveCallback: false,
    );
    var observeResult = result.observeResult;
    final displayingChildModelList =
        observeResult?.displayingChildModelList ?? [];
    expect(displayingChildModelList, isNotEmpty);
    expect(observeResult?.firstChild?.index, 0);
    expect(observeResult?.firstChild?.leadingMarginToViewport, 0);

    // Check adjustPosition.
    key.currentState?.updateData(
      index: 1,
      needSetState: true,
    );
    double? adjustPosition;
    await chatScrollObserver.standby(
      mode: ChatScrollObserverHandleMode.specified,
      refIndexType: ChatScrollObserverRefIndexType.itemIndex,
      refItemIndex: 0,
      refItemIndexAfterUpdate: 0,
      customAdjustPositionDelta: (model) {
        adjustPosition = model.adjustPosition;
        return null;
      },
    );
    await tester.pumpAndSettle();
    expect(adjustPosition, 0);

    result = await observerController.dispatchOnceObserve(
      isForce: true,
      isDependObserveCallback: false,
    );
    observeResult = result.observeResult;
    expect(observeResult?.firstChild?.index, 0);
    expect(observeResult?.firstChild?.leadingMarginToViewport, 0);

    final targetIndex = displayingChildModelList.last.index + 1;
    // Jump to targetIndex and align its bottom with the viewport bottom.
    observerController.jumpTo(
      index: targetIndex,
      offset: (targetOffset) {
        final viewportMainAxisExtent =
            observeResult?.firstChild?.viewportMainAxisExtent ?? 0;
        return viewportMainAxisExtent - normalItemHeight;
      },
    );
    await tester.pumpAndSettle();
    await tester.pump(observerController.observeIntervalForScrolling);

    // Check if the last item is aligned with the viewport bottom.
    result = await observerController.dispatchOnceObserve(
      isForce: true,
      isDependObserveCallback: false,
    );
    observeResult = result.observeResult;
    var lastDisplayingChildModel = observeResult?.displayingChildModelList.last;
    expect(lastDisplayingChildModel?.index, targetIndex);
    expect(lastDisplayingChildModel?.trailingMarginToViewport, 0);

    // Expand the last item.
    itemHeightMap[targetIndex] = expandedItemHeight;
    final refItemIndex = targetIndex;
    await chatScrollObserver.standby(
      mode: ChatScrollObserverHandleMode.specified,
      refIndexType: ChatScrollObserverRefIndexType.itemIndex,
      refItemIndex: refItemIndex,
      refItemIndexAfterUpdate: refItemIndex,
      customAdjustPositionDelta: (model) {
        return expandedItemHeight - normalItemHeight;
      },
    );
    await setState();
    result = await observerController.dispatchOnceObserve(
      isForce: true,
      isDependObserveCallback: false,
    );
    observeResult = result.observeResult;
    lastDisplayingChildModel = observeResult?.displayingChildModelList.last;
    expect(lastDisplayingChildModel?.index, targetIndex);
    expect(lastDisplayingChildModel?.trailingMarginToViewport, 0);

    // Restore the last item to normal height.
    itemHeightMap[targetIndex] = normalItemHeight;
    await chatScrollObserver.standby(
      mode: ChatScrollObserverHandleMode.specified,
      refIndexType: ChatScrollObserverRefIndexType.itemIndex,
      refItemIndex: refItemIndex,
      refItemIndexAfterUpdate: refItemIndex,
      customAdjustPositionDelta: (model) {
        adjustPosition = model.adjustPosition;
        return normalItemHeight - expandedItemHeight;
      },
    );
    await setState();
    result = await observerController.dispatchOnceObserve(
      isForce: true,
      isDependObserveCallback: false,
    );
    observeResult = result.observeResult;
    lastDisplayingChildModel = observeResult?.displayingChildModelList.last;
    expect(lastDisplayingChildModel?.index, targetIndex);
    expect(lastDisplayingChildModel?.trailingMarginToViewport, 0);
    expect(adjustPosition, greaterThan(0));

    scrollController.dispose();
  });

  testWidgets('Keeping position with customAdjustPosition', (tester) async {
    GlobalKey<ChatListViewState> key = GlobalKey();
    final scrollController = ScrollController();
    final observerController = ListObserverController(
      controller: scrollController,
    );
    ChatScrollObserverHandlePositionResultModel? onHandlePositionResultModel;
    final chatScrollObserver = ChatScrollObserver(observerController)
      ..onHandlePositionResultCallback = (model) {
        onHandlePositionResultModel = model;
      };

    Widget widget = ChatListView(
      key: key,
      scrollController: scrollController,
      observerController: observerController,
      chatScrollObserver: chatScrollObserver,
      itemBuilder: (context, index) {
        final dataList = key.currentState?.dataList ?? [];
        return Text(dataList[index]);
      },
    );
    await tester.pumpWidget(widget);

    final chatListViewState = key.currentState;
    expect(chatListViewState, isNotNull);

    final dataListLength = chatListViewState?.dataList.length ?? 0;
    final lastIndex = dataListLength - 1;
    observerController.jumpTo(index: lastIndex);
    await tester.pumpAndSettle();

    var result = await observerController.dispatchOnceObserve(
      isForce: true,
      isDependObserveCallback: false,
    );
    var lastModel = result.observeResult?.displayingChildModelList.last;
    expect(lastModel?.index, lastIndex);
    expect(lastModel?.trailingMarginToViewport, 0);
    expect(onHandlePositionResultModel, isNull);

    chatListViewState?.updateData(
      index: lastIndex,
      needSetState: true,
    );
    await chatScrollObserver.standby(
      customAdjustPosition: (model) {
        final delta =
            model.newPosition.extentAfter - model.oldPosition.extentAfter;
        return model.adjustPosition + delta;
      },
    );
    await tester.pumpAndSettle();

    result = await observerController.dispatchOnceObserve(
      isForce: true,
      isDependObserveCallback: false,
    );
    lastModel = result.observeResult?.displayingChildModelList.last;
    expect(lastModel?.index, lastIndex);
    expect(lastModel?.trailingMarginToViewport, 0);
    expect(
      onHandlePositionResultModel?.type,
      ChatScrollObserverHandlePositionType.keepPosition,
    );

    scrollController.dispose();
  });
}

class ChatListView extends StatefulWidget {
  const ChatListView({
    Key? key,
    required this.scrollController,
    required this.observerController,
    required this.chatScrollObserver,
    this.onReceiveScrollNotification,
    this.itemBuilder,
    this.dataList,
  }) : super(key: key);

  final ScrollController scrollController;
  final ListObserverController observerController;
  final ChatScrollObserver chatScrollObserver;
  final Function()? onReceiveScrollNotification;
  final NullableIndexedWidgetBuilder? itemBuilder;
  final List<String>? dataList;

  @override
  State<ChatListView> createState() => ChatListViewState();
}

class ChatListViewState extends State<ChatListView> {
  late List<String> dataList = widget.dataList ??
      List.generate(100, (index) => index.toString()).toList();

  void initData({
    required List<String> dataList,
    bool needSetState = true,
  }) {
    this.dataList = dataList;
    if (needSetState) {
      setState(() {});
    }
  }

  void updateData({
    int index = 0,
    String? appendStr,
    bool needSetState = true,
  }) {
    dataList[index] += appendStr ?? 'updateData' * 10;
    if (needSetState) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(),
        body: _buildListView(),
        floatingActionButton: Column(
          verticalDirection: VerticalDirection.up,
          children: [
            FloatingActionButton(
              onPressed: () {
                widget.chatScrollObserver.standby(changeCount: 4);
                setState(() {
                  dataList.insert(0, '-1');
                  dataList.insert(0, '-2');
                  dataList.insert(0, '-3');
                  dataList.insert(0, '-4');
                });
              },
              child: const Icon(Icons.add),
            ),
            FloatingActionButton(
              onPressed: () {
                setState(() {});
              },
              child: const Icon(Icons.refresh),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView() {
    Widget resultWidget = ListViewObserver(
      controller: widget.observerController,
      child: ListView.builder(
        itemCount: dataList.length,
        physics: ChatObserverBouncingScrollPhysics(
          observer: widget.chatScrollObserver,
        ),
        controller: widget.scrollController,
        itemBuilder: widget.itemBuilder ??
            (context, index) {
              return SizedBox(
                height: 100,
                child: Center(child: Text(dataList[index])),
              );
            },
      ),
    );
    resultWidget = NotificationListener<ScrollNotification>(
      child: resultWidget,
      onNotification: (notification) {
        widget.onReceiveScrollNotification?.call();
        return false;
      },
    );
    return resultWidget;
  }
}
