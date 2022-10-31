/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Reop: https://github.com/LinXunFeng/flutter_scrollview_observer
 * @Date: 2022-08-29 23:43:08
 */

import 'package:flutter/material.dart';
import 'package:scrollview_observer/scrollview_observer.dart';
import 'package:scrollview_observer_example/features/scene/chat_demo/helper/chat_data_helper.dart';
import 'package:scrollview_observer_example/features/scene/chat_demo/model/chat_model.dart';
import 'package:scrollview_observer_example/features/scene/chat_demo/widget/chat_item_widget.dart';
import 'package:scrollview_observer_example/features/scene/chat_demo/widget/chat_unread_tip_view.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  ScrollController scrollController = ScrollController();

  late ListObserverController observerController;

  late ChatScrollObserver chatObserver;

  List<ChatModel> chatModels = [];

  ValueNotifier<int> unreadMsgCount = ValueNotifier<int>(0);

  bool needIncrementUnreadMsgCount = false;

  @override
  void initState() {
    super.initState();

    chatModels = createChatModels();

    scrollController.addListener(scrollControllerListener);

    observerController = ListObserverController(controller: scrollController)
      ..cacheJumpIndexOffset = false;

    chatObserver = ChatScrollObserver(observerController)
      ..toRebuildScrollViewCallback = () {
        setState(() {});
      }
      ..onHandlePositionCallback = (type) {
        if (!needIncrementUnreadMsgCount) return;
        switch (type) {
          case ChatScrollObserverHandlePositionType.keepPosition:
            updateUnreadMsgCount();
            break;
          case ChatScrollObserverHandlePositionType.none:
            updateUnreadMsgCount(isReset: true);
            break;
        }
      };
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 7, 7, 7),
      appBar: AppBar(
        title: const Text("Chat"),
        backgroundColor: const Color.fromARGB(255, 19, 19, 19),
        actions: [
          IconButton(
            onPressed: () {
              chatObserver.standby();
              setState(() {
                chatModels.insert(0, ChatDataHelper.createChatModel());
                needIncrementUnreadMsgCount = true;
              });
            },
            icon: const Icon(Icons.add_comment),
          )
        ],
      ),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    return Stack(
      children: [
        _buildListView(),
        Positioned(
          bottom: 0,
          right: 30,
          child: _buildUnreadTipView(),
        ),
      ],
    );
  }

  Widget _buildUnreadTipView() {
    return ValueListenableBuilder<int>(
      builder: (context, value, child) {
        return ChatUnreadTipView(
          unreadMsgCount: unreadMsgCount.value,
          onTap: () {
            scrollController.animateTo(
              0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
            updateUnreadMsgCount(isReset: true);
          },
        );
      },
      valueListenable: unreadMsgCount,
    );
  }

  Widget _buildListView() {
    Widget resultWidget = ListView.builder(
      physics: ChatObserverClampinScrollPhysics(observer: chatObserver),
      padding: const EdgeInsets.only(left: 10, right: 10, top: 15, bottom: 15),
      shrinkWrap: chatObserver.isShrinkWrap,
      reverse: true,
      controller: scrollController,
      itemBuilder: ((context, index) {
        return ChatItemWidget(
          chatModel: chatModels[index],
          index: index,
          onRemove: () {
            chatObserver.standby(isRemove: true);
            setState(() {
              chatModels.removeAt(index);
            });
          },
        );
      }),
      itemCount: chatModels.length,
      clipBehavior: Clip.none,
    );

    resultWidget = ListViewObserver(
      controller: observerController,
      child: resultWidget,
    );
    return resultWidget;
  }

  List<ChatModel> createChatModels({int num = 3}) {
    return Iterable<int>.generate(num)
        .map((e) => ChatDataHelper.createChatModel())
        .toList();
  }

  updateUnreadMsgCount({bool isReset = false}) {
    needIncrementUnreadMsgCount = false;
    if (isReset) {
      unreadMsgCount.value = 0;
    } else {
      unreadMsgCount.value += 1;
    }
  }

  scrollControllerListener() {
    if (scrollController.offset < 50) {
      updateUnreadMsgCount(isReset: true);
    }
  }
}
