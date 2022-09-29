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

  @override
  void initState() {
    super.initState();

    chatModels = createChatModels();

    observerController = ListObserverController(controller: scrollController)
      ..cacheJumpIndexOffset = false;

    chatObserver = ChatScrollObserver(observerController)
      ..toRebuildScrollViewCallback = () {
        setState(() {});
      };
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
              });
            },
            icon: const Icon(Icons.add_comment),
          )
        ],
      ),
      body: SafeArea(child: _buildListView()),
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
}
