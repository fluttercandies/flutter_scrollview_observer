/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/fluttercandies/flutter_scrollview_observer
 * @Date: 2023-10-25 22:07:29
 */

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:scrollview_observer/scrollview_observer.dart';
import 'package:scrollview_observer_example/features/scene/azlist_demo/azlist_cursor.dart';
import 'package:scrollview_observer_example/features/scene/azlist_demo/azlist_item_view.dart';
import 'package:scrollview_observer_example/features/scene/azlist_demo/azlist_model.dart';
import 'package:scrollview_observer_example/features/scene/azlist_demo/azlist_index_bar.dart';

class AzListPage extends StatefulWidget {
  const AzListPage({Key? key}) : super(key: key);

  @override
  State<AzListPage> createState() => _AzListPageState();
}

class _AzListPageState extends State<AzListPage> {
  List<AzListContactModel> contactList = [];

  List<String> get symbols => contactList.map((e) => e.section).toList();

  final indexBarContainerKey = GlobalKey();

  bool isShowListMode = true;

  ValueNotifier<AzListCursorInfoModel?> cursorInfo = ValueNotifier(null);

  double indexBarWidth = 20;

  ScrollController scrollController = ScrollController();

  late SliverObserverController observerController;

  Map<int, BuildContext> sliverContextMap = {};

  generateContactData() {
    final a = const Utf8Codec().encode("A").first;
    final z = const Utf8Codec().encode("Z").first;
    int pointer = a;
    while (pointer >= a && pointer <= z) {
      final character = const Utf8Codec().decode(Uint8List.fromList([pointer]));
      contactList.add(
        AzListContactModel(
          section: character,
          names: List.generate(Random().nextInt(8), (index) {
            return '$character-$index';
          }),
        ),
      );
      pointer++;
    }
  }

  @override
  void initState() {
    super.initState();

    observerController = SliverObserverController(controller: scrollController);

    generateContactData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 243, 244, 246),
      appBar: AppBar(
        title: const Text("AzListPage"),
        backgroundColor: const Color.fromARGB(255, 243, 244, 246),
        shadowColor: Colors.transparent,
        foregroundColor: Colors.black,
        actions: [_buildSwitchModeBtn()],
      ),
      body: Stack(
        children: [
          SliverViewObserver(
            controller: observerController,
            sliverContexts: () {
              return sliverContextMap.values.toList();
            },
            child: CustomScrollView(
              key: ValueKey(isShowListMode),
              controller: scrollController,
              slivers: contactList.mapIndexed((i, e) {
                return _buildSliver(index: i, model: e);
              }).toList(),
            ),
          ),
          _buildCursor(),
          Positioned(
            top: 0,
            bottom: 0,
            right: 0,
            child: _buildIndexBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchModeBtn() {
    return IconButton(
      onPressed: () {
        setState(() {
          isShowListMode = !isShowListMode;
          // Clear the offset cache.
          for (var ctx in sliverContextMap.values) {
            observerController.clearScrollIndexCache(sliverContext: ctx);
          }
          sliverContextMap.clear();
        });
        observerController.reattach();
      },
      icon: const Icon(Icons.swap_horizontal_circle_sharp),
    );
  }

  Widget _buildCursor() {
    return ValueListenableBuilder<AzListCursorInfoModel?>(
      valueListenable: cursorInfo,
      builder: (
        BuildContext context,
        AzListCursorInfoModel? value,
        Widget? child,
      ) {
        Widget resultWidget = Container();
        double top = 0;
        double right = indexBarWidth + 8;
        if (value == null) {
          resultWidget = const SizedBox.shrink();
        } else {
          double titleSize = 80;
          top = value.offset.dy - titleSize * 0.5;
          resultWidget = AzListCursor(size: titleSize, title: value.title);
        }
        resultWidget = Positioned(
          top: top,
          right: right,
          child: resultWidget,
        );
        return resultWidget;
      },
    );
  }

  Widget _buildIndexBar() {
    return Container(
      key: indexBarContainerKey,
      width: indexBarWidth,
      alignment: Alignment.center,
      child: AzListIndexBar(
        parentKey: indexBarContainerKey,
        symbols: symbols,
        onSelectionUpdate: (index, cursorOffset) {
          cursorInfo.value = AzListCursorInfoModel(
            title: symbols[index],
            offset: cursorOffset,
          );
          final sliverContext = sliverContextMap[index];
          if (sliverContext == null) return;
          observerController.jumpTo(
            index: 0,
            sliverContext: sliverContext,
          );
        },
        onSelectionEnd: () {
          cursorInfo.value = null;
        },
      ),
    );
  }

  Widget _buildSliver({
    required int index,
    required AzListContactModel model,
  }) {
    final names = model.names;
    if (names.isEmpty) return const SliverToBoxAdapter();
    Widget resultWidget = isShowListMode
        ? SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, itemIndex) {
                if (sliverContextMap[index] == null) {
                  sliverContextMap[index] = context;
                }
                return AzListItemView(name: names[itemIndex]);
              },
              childCount: names.length,
            ),
          )
        : SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, //Grid按两列显示
              mainAxisSpacing: 10.0,
              crossAxisSpacing: 10.0,
              childAspectRatio: 2.0,
            ),
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int itemIndex) {
                if (sliverContextMap[index] == null) {
                  sliverContextMap[index] = context;
                }
                return AzListItemView(
                  name: names[itemIndex],
                  isShowSeparator: false,
                );
              },
              childCount: names.length,
            ),
          );
    resultWidget = SliverStickyHeader(
      header: Container(
        height: 44.0,
        color: const Color.fromARGB(255, 243, 244, 246),
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        alignment: Alignment.centerLeft,
        child: Text(
          model.section,
          style: const TextStyle(color: Colors.black54),
        ),
      ),
      sliver: resultWidget,
    );
    return resultWidget;
  }
}
