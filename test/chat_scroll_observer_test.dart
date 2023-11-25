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
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    final result = await observerController.dispatchOnceObserve(
      isForce: true,
      isDependObserveCallback: false,
    );
    expect(result.observeResult?.firstChild?.index, 4);
    expect(receiveScrollNotificationCount, 0);

    scrollController.dispose();
  });
}

class ChatListView extends StatefulWidget {
  const ChatListView({
    Key? key,
    required this.scrollController,
    required this.observerController,
    required this.chatScrollObserver,
    required this.onReceiveScrollNotification,
  }) : super(key: key);

  final ScrollController scrollController;
  final ListObserverController observerController;
  final ChatScrollObserver chatScrollObserver;
  final Function()? onReceiveScrollNotification;

  @override
  State<ChatListView> createState() => _ChatListViewState();
}

class _ChatListViewState extends State<ChatListView> {
  List<String> dataList =
      List.generate(100, (index) => index.toString()).toList();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(),
        body: _buildListView(),
        floatingActionButton: FloatingActionButton(
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
        itemBuilder: (context, index) {
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
