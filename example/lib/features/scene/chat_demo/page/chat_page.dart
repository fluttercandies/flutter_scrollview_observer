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

  bool editViewReadOnly = false;

  TextEditingController editViewController = TextEditingController();

  BuildContext? pageOverlayContext;

  final LayerLink layerLink = LayerLink();

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

    Future.delayed(const Duration(seconds: 1), addUnreadTipView);
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
              editViewController.text = '';
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
      body: _buildBody(),
    );
  }

  Widget _buildPageOverlay() {
    return Overlay(initialEntries: [
      OverlayEntry(
        builder: (context) {
          pageOverlayContext = context;
          return Container();
        },
      )
    ]);
  }

  Widget _buildBody() {
    Widget resultWidget = Column(
      children: [
        Expanded(child: _buildListView()),
        CompositedTransformTarget(
          link: layerLink,
          child: Container(),
        ),
        _buildEditView(),
        const SafeArea(top: false, child: SizedBox.shrink()),
      ],
    );
    resultWidget = Stack(children: [
      resultWidget,
      _buildPageOverlay(),
    ]);
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

  addUnreadTipView() {
    Overlay.of(pageOverlayContext!)?.insert(OverlayEntry(
      builder: (BuildContext context) => UnconstrainedBox(
        child: CompositedTransformFollower(
          link: layerLink,
          followerAnchor: Alignment.bottomRight,
          targetAnchor: Alignment.topRight,
          offset: const Offset(-20, 0),
          child: Material(
            type: MaterialType.transparency,
            // color: Colors.green,
            child: _buildUnreadTipView(),
          ),
        ),
      ),
    ));
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
