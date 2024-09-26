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

  List<String> pageItemBgPicList = [
    '11898897',
    '26653530',
    '12974784',
    '943459',
    '4424178',
    '20433037',
    '4424137',
    '4955810',
    '4424137',
    '18847956',
  ]
      .map((id) =>
          'https://images.pexels.com/photos/$id/pexels-photo-$id.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2')
      .toList();

  int get pageItemCount => pageItemBgPicList.length;

  List<ValueNotifier<double>> pageItemOffsetYList = [];

  final observerController = ListObserverController();

  @override
  void initState() {
    super.initState();
    pageController = PageController(
      initialPage: 4,
      viewportFraction: 0.8,
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
    for (var e in pageItemOffsetYList) {
      e.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "PageView",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.black87,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
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
        'https://images.pexels.com/photos/41949/earth-earth-at-night-night-lights-41949.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',
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
        return _buildPageItem(index);
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

          // Calculates pageItemOffsetY
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

  Widget _buildPageItem(int index) {
    Widget itemWidget = Container(
      decoration: BoxDecoration(
        color: Colors.blue[100],
        borderRadius: BorderRadius.circular(4),
      ),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            bottom: 0,
            child: _buildPageItemBgPicView(index),
          ),
          const SizedBox.expand(),
          Container(
            width: double.infinity,
            alignment: Alignment.center,
            height: 44,
            decoration: const BoxDecoration(
              color: Colors.white54,
            ),
            child: Text("Page $index"),
          ),
        ],
      ),
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
  }

  Widget _buildPageItemBgPicView(int index) {
    return Image.network(
      pageItemBgPicList[index],
      fit: BoxFit.cover,
    );
  }
}
