/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/fluttercandies/flutter_scrollview_observer
 * @Date: 2023-12-31 14:00:51
 */

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:scrollview_observer/scrollview_observer.dart';

class InfiniteListViewPage extends StatefulWidget {
  const InfiniteListViewPage({Key? key}) : super(key: key);

  @override
  State<InfiniteListViewPage> createState() => _InfiniteListViewPageState();
}

class _InfiniteListViewPageState extends State<InfiniteListViewPage> {
  List<int> dataSource = [];

  bool isLoadingForHeader = false;

  bool isLoadingForFooter = false;

  final double itemMinHeight = 50;

  final double itemMaxHeight = 150;

  final Random _random = Random();

  double get randomItemHeight =>
      itemMinHeight + _random.nextInt((itemMaxHeight - itemMinHeight).toInt());

  List<double> itemHeights = [];

  int generateCount = 20;

  ScrollController scrollController = ScrollController();

  late ListObserverController observerController;

  late ChatScrollObserver chatObserver;

  handleLoadMoreForHeader() async {
    if (isLoadingForHeader) return; // loading
    isLoadingForHeader = true;
    int initIndex = 0;
    if (dataSource.isNotEmpty) {
      initIndex = dataSource.first;
    }
    await Future.delayed(const Duration(milliseconds: 100));
    dataSource.insertAll(
      0,
      List.generate(generateCount, (index) {
        return initIndex - (generateCount - index);
      }),
    );
    itemHeights.insertAll(
      0,
      List.generate(generateCount, (_) => randomItemHeight),
    );
    // Keeping position
    chatObserver.standby(changeCount: generateCount);
    // Clearing the offset cache
    observerController.clearScrollIndexCache();
    setState(() {});

    isLoadingForHeader = false;
  }

  handleLoadMoreForFooter() async {
    if (isLoadingForFooter) return; // loading
    isLoadingForFooter = true;
    int initIndex = 0;
    if (dataSource.isNotEmpty) {
      initIndex = dataSource.last;
    }
    await Future.delayed(const Duration(milliseconds: 100));
    setState(() {
      dataSource.addAll(
        List.generate(generateCount, (index) => index + initIndex + 1),
      );
      itemHeights.addAll(
        List.generate(generateCount, (_) => randomItemHeight),
      );
    });
    isLoadingForFooter = false;
  }

  @override
  void initState() {
    super.initState();

    observerController = ListObserverController(controller: scrollController)
      ..initialIndex = generateCount ~/ 2;

    chatObserver = ChatScrollObserver(observerController)
      ..fixedPositionOffset = -double.maxFinite
      ..toRebuildScrollViewCallback = () {
        setState(() {});
      };

    dataSource = List.generate(generateCount, (index) => index);
    itemHeights = List.generate(generateCount, (_) => randomItemHeight);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("ListView")),
      body: ListViewObserver(
        controller: observerController,
        triggerOnObserveType: ObserverTriggerOnObserveType.directly,
        child: _buildListView(),
        onObserve: (result) {
          debugPrint(
              'displaying -- ${result.displayingChildIndexList.map((i) => dataSource[i])}');

          if (result.firstChild?.index == 0) {
            final firstChildLeadingMarginToViewport =
                result.firstChild?.leadingMarginToViewport ?? 0;
            if (firstChildLeadingMarginToViewport > -100) {
              handleLoadMoreForHeader();
            }
          } else if (result.displayingChildIndexList.last ==
              dataSource.length - 1) {
            final lastChildTrailingMarginToViewport =
                result.displayingChildModelList.last.trailingMarginToViewport;
            if (lastChildTrailingMarginToViewport < 100) {
              handleLoadMoreForFooter();
            }
          }
        },
      ),
    );
  }

  Widget _buildListView() {
    return ListView.separated(
      physics: ChatObserverClampingScrollPhysics(observer: chatObserver),
      padding: EdgeInsets.zero,
      controller: scrollController,
      itemBuilder: (ctx, index) {
        return _buildListItemView(index);
      },
      separatorBuilder: (ctx, index) {
        return _buildSeparatorView();
      },
      itemCount: dataSource.length,
      // Ensure that the reference item can be found when keeping position.
      cacheExtent: itemMaxHeight * (generateCount + 2),
    );
  }

  Widget _buildListItemView(int index) {
    return Container(
      height: itemHeights[index],
      color: index % 2 == 0 ? Colors.black26 : Colors.black12,
      child: Center(
        child: Text(
          "index -- ${dataSource[index]}",
          style: const TextStyle(
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildSeparatorView() {
    return Container(
      color: Colors.white,
      width: 5,
    );
  }
}
