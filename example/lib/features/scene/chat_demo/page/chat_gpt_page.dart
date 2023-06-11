/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/LinXunFeng/flutter_scrollview_observer
 * @Date: 2023-06-04 15:12:22
 */

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:scrollview_observer/scrollview_observer.dart';
import 'package:scrollview_observer_example/features/scene/chat_demo/helper/chat_data_helper.dart';
import 'package:scrollview_observer_example/features/scene/chat_demo/model/chat_model.dart';
import 'package:scrollview_observer_example/features/scene/chat_demo/widget/chat_item_widget.dart';

class ChatGPTPage extends StatefulWidget {
  const ChatGPTPage({Key? key}) : super(key: key);

  @override
  State<ChatGPTPage> createState() => _ChatGPTPageState();
}

class _ChatGPTPageState extends State<ChatGPTPage> {
  ScrollController scrollController = ScrollController();

  late ListObserverController observerController;

  late ChatScrollObserver chatObserver;

  List<ChatModel> chatModels = [];

  bool editViewReadOnly = false;

  TextEditingController editViewController = TextEditingController();

  Timer? timer;

  @override
  void initState() {
    super.initState();

    chatModels = createChatModels(num: 8);

    observerController = ListObserverController(controller: scrollController)
      ..cacheJumpIndexOffset = false;

    chatObserver = ChatScrollObserver(observerController)
      ..fixedPositionOffset = 5
      ..toRebuildScrollViewCallback = () {
        setState(() {});
      };
  }

  @override
  void dispose() {
    stopMsgUpdateStream();
    observerController.controller?.dispose();
    editViewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 7, 7, 7),
      appBar: AppBar(
        title: const Text("ChatGPT"),
        backgroundColor: const Color.fromARGB(255, 19, 19, 19),
        actions: [
          IconButton(
            onPressed: () async {
              editViewController.text = '';
              stopMsgUpdateStream();
              _addMessage(isOwn: true);
              await Future.delayed(const Duration(seconds: 1));
              insertGenerativeMsg();
            },
            icon: const Icon(Icons.add_comment),
          )
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    Widget resultWidget = Column(
      children: [
        Expanded(child: _buildListView()),
        _buildEditView(),
        const SafeArea(top: false, child: SizedBox.shrink()),
      ],
    );
    return resultWidget;
  }

  Widget _buildEditView() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 0.5),
        borderRadius: BorderRadius.circular(4),
        // color: Colors.white,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: const InputDecoration(
                border: InputBorder.none,
                isCollapsed: true,
              ),
              style: const TextStyle(color: Colors.white),
              maxLines: 4,
              minLines: 1,
              showCursor: true,
              readOnly: editViewReadOnly,
              controller: editViewController,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.emoji_emotions_outlined),
            iconSize: 24,
            color: Colors.white,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightForFinite(),
            onPressed: () {
              setState(() {
                editViewReadOnly = !editViewReadOnly;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildListView() {
    Widget resultWidget = ListView.builder(
      physics: ChatObserverClampingScrollPhysics(observer: chatObserver),
      padding: const EdgeInsets.only(left: 10, right: 10, top: 15, bottom: 15),
      shrinkWrap: chatObserver.isShrinkWrap,
      reverse: true,
      controller: scrollController,
      itemBuilder: ((context, index) {
        return ChatItemWidget(
          chatModel: chatModels[index],
          index: index,
          itemCount: chatModels.length,
          onRemove: () {
            chatObserver.standby(isRemove: true);
            setState(() {
              chatModels.removeAt(index);
            });
          },
        );
      }),
      itemCount: chatModels.length,
    );

    resultWidget = ListViewObserver(
      controller: observerController,
      child: resultWidget,
    );
    resultWidget = Align(
      child: resultWidget,
      alignment: Alignment.topCenter,
    );
    return resultWidget;
  }

  List<ChatModel> createChatModels({int num = 3}) {
    return Iterable<int>.generate(num)
        .map((e) => ChatDataHelper.createChatModel())
        .toList();
  }

  _addMessage({
    required bool isOwn,
  }) {
    chatObserver.standby(changeCount: 1);
    setState(() {
      chatModels.insert(0, ChatDataHelper.createChatModel(isOwn: isOwn));
    });
  }

  insertGenerativeMsg() {
    stopMsgUpdateStream();
    _addMessage(isOwn: false);
    int count = 0;
    timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (count >= 60) {
        stopMsgUpdateStream();
        return;
      }
      count++;
      final model = chatModels.first;
      final newString = '${model.content}-1+1';
      final newModel = ChatModel(isOwn: model.isOwn, content: newString);
      chatModels[0] = newModel;
      chatObserver.standby(
        mode: ChatScrollObserverHandleMode.generative,
        // changeCount: 1,
      );
      // chatObserver.standby(
      //   changeCount: 1,
      //   mode: ChatScrollObserverHandleMode.specified,
      //   refItemRelativeIndex: 2,
      //   refItemRelativeIndexAfterUpdate: 2,
      // );
      setState(() {});
    });
  }

  stopMsgUpdateStream() {
    timer?.cancel();
    timer = null;
  }
}
