/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/fluttercandies/flutter_scrollview_observer
 * @Date: 2024-08-26 21:30:59
 */

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:scrollview_observer/scrollview_observer.dart';

class PageViewParallaxPage extends StatefulWidget {
  const PageViewParallaxPage({Key? key}) : super(key: key);

  @override
  State<PageViewParallaxPage> createState() => _PageViewParallaxPageState();
}

class _PageViewParallaxPageState extends State<PageViewParallaxPage> {
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

  List<ValueNotifier<double>> pageItemBgPicAlignmentXList = [];

  final observerController = ListObserverController();

  @override
  void initState() {
    super.initState();
    pageController = PageController(
      initialPage: 4,
      viewportFraction: 0.9,
    );
    pageItemBgPicAlignmentXList = List.generate(
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
    for (var e in pageItemBgPicAlignmentXList) {
      e.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber[50],
      appBar: AppBar(
        title: const Text(
          "PageView - Parallax",
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
      body: Center(
        child: _buildPageView(),
      ),
    );
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

          // Calculates itemAlignmentX
          double itemAlignmentX = 1 - itemDisplayPercentage;
          if (itemModel.leadingMarginToViewport > 0) {
            itemAlignmentX = -itemAlignmentX;
          }
          if (itemAlignmentX > 1) {
            itemAlignmentX = 1;
          } else if (itemAlignmentX < -1) {
            itemAlignmentX = -1;
          }
          pageItemBgPicAlignmentXList[itemIndex].value = itemAlignmentX;
        }
      },
      customTargetRenderSliverType: (renderObj) {
        return renderObj is RenderSliverFillViewport;
      },
    );

    resultWidget = SizedBox(
      height: (MediaQuery.sizeOf(context).height -
              MediaQuery.paddingOf(context).top -
              kToolbarHeight) *
          0.8,
      child: resultWidget,
    );
    return resultWidget;
  }

  Widget _buildPageItem(int index) {
    Widget resultWidget = Stack(
      alignment: AlignmentDirectional.center,
      children: [
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          bottom: 0,
          child: _buildPageItemBgPicView(index),
        ),
        const SizedBox.expand(),
        _buildNum(index),
      ],
    );
    resultWidget = Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(10),
      ),
      child: resultWidget,
    );
    return resultWidget;
  }

  Widget _buildNum(int index) {
    return Container(
      alignment: Alignment.center,
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text("Page $index"),
    );
  }

  Widget _buildPageItemBgPicView(int index) {
    return ValueListenableBuilder(
      valueListenable: pageItemBgPicAlignmentXList[index],
      builder: (BuildContext context, double alignmentX, Widget? child) {
        return Image.network(
          pageItemBgPicList[index],
          fit: BoxFit.cover,
          alignment: Alignment(alignmentX, 0),
        );
      },
    );
  }
}
