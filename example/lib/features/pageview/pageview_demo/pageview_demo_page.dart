/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/fluttercandies/flutter_scrollview_observer
 * @Date: 2024-08-03 14:09:53
 */

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:scrollview_observer/scrollview_observer.dart';

class PageViewDemoPage extends StatefulWidget {
  const PageViewDemoPage({Key? key}) : super(key: key);

  @override
  State<PageViewDemoPage> createState() => _PageViewDemoPageState();
}

class _PageViewDemoPageState extends State<PageViewDemoPage> {
  double offsetYDelta = 50;

  late PageController pageController;

  int pageItemCount = 10;

  List<ValueNotifier<double>> pageItemOffsetYList = [];

  final observerController = ListObserverController();

  @override
  void initState() {
    super.initState();
    pageController = PageController(
      initialPage: 4,
      viewportFraction: 0.9,
    );
    pageItemOffsetYList = List.generate(
      pageItemCount,
      (index) {
        return ValueNotifier<double>(0);
      },
    );

    Future.delayed(const Duration(milliseconds: 100)).then((_) {
      observerController.dispatchOnceObserve();
    });
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PageView"),
      ),
      body: Stack(
        children: [
          _buildMap(),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildPageView(),
          ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    Widget resultWidget = SizedBox(
      width: 500,
      height: 900,
      child: Image.network(
        'https://img2.baidu.com/it/u=675935710,2689018786&fm=253&fmt=auto&app=138&f=JPG?w=1061&h=500',
        fit: BoxFit.fitHeight,
      ),
    );
    resultWidget = Stack(
      children: [
        resultWidget,
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          bottom: 0,
          child: Container(
            color: Colors.black38,
          ),
        ),
      ],
    );
    return resultWidget;
  }

  Widget _buildPageView() {
    Widget resultWidget = PageView.builder(
      controller: pageController,
      itemBuilder: (context, index) {
        Widget itemWidget = Container(
          decoration: BoxDecoration(
            color: Colors.blue[100],
            borderRadius: BorderRadius.circular(4),
          ),
          alignment: Alignment.center,
          child: Text("Page $index"),
        );
        Widget resultWidget = ValueListenableBuilder(
          valueListenable: pageItemOffsetYList[index],
          builder: (BuildContext context, double offsetY, Widget? child) {
            return Transform.translate(
              offset: Offset(0, offsetY),
              child: itemWidget,
            );
          },
        );
        resultWidget = Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          child: resultWidget,
        );
        return resultWidget;
      },
      itemCount: pageItemCount,
    );
    resultWidget = ListViewObserver(
      controller: observerController,
      child: resultWidget,
      triggerOnObserveType: ObserverTriggerOnObserveType.directly,
      onObserve: (resultModel) {
        final displayingChildModelList = resultModel.displayingChildModelList;
        for (var itemModel in displayingChildModelList) {
          final itemIndex = itemModel.index;
          final itemDisplayPercentage = itemModel.displayPercentage;
          final offsetY = (1 - itemDisplayPercentage) * offsetYDelta;
          pageItemOffsetYList[itemIndex].value = offsetY;
        }
      },
      customTargetRenderSliverType: (renderObj) {
        return renderObj is RenderSliverFillViewport;
      },
    );
    resultWidget = SizedBox(
      height: 300,
      child: resultWidget,
    );
    return resultWidget;
  }
}
