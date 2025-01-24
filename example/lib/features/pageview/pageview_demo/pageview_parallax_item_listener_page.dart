/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/fluttercandies/flutter_scrollview_observer
 * @Date: 2024-11-14 22:41:51
 */

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:scrollview_observer/scrollview_observer.dart';

class PageViewParallaxItemListenerPage extends StatefulWidget {
  const PageViewParallaxItemListenerPage({Key? key}) : super(key: key);

  @override
  State<PageViewParallaxItemListenerPage> createState() =>
      _PageViewParallaxItemListenerPageState();
}

class _PageViewParallaxItemListenerPageState
    extends State<PageViewParallaxItemListenerPage> {
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
        // return _buildPageItem(index);
        return ParallaxItemView(
          index: index,
          imgUrl: pageItemBgPicList[index],
        );
      },
      itemCount: pageItemCount,
    );
    resultWidget = ListViewObserver(
      controller: observerController,
      child: resultWidget,
      triggerOnObserveType: ObserverTriggerOnObserveType.directly,
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
}

class ParallaxItemView extends StatefulWidget {
  final int index;
  final String imgUrl;

  const ParallaxItemView({
    Key? key,
    required this.index,
    required this.imgUrl,
  }) : super(key: key);

  @override
  State<ParallaxItemView> createState() => _ParallaxItemViewState();
}

class _ParallaxItemViewState extends State<ParallaxItemView> {
  ListViewObserverState? observerState;

  final picAlignmentX = ValueNotifier<double>(0);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    removeListener();
    observerState = ListViewObserver.of(context)
      ..addListener(
        onObserve: handleObserverResult,
      );
  }

  @override
  void dispose() {
    removeListener();
    picAlignmentX.dispose();
    super.dispose();
  }

  void removeListener() {
    observerState?.removeListener(
      onObserve: handleObserverResult,
    );
    observerState = null;
  }

  void handleObserverResult(
    ListViewObserveModel result,
  ) {
    if (result.displayingChildModelMap.isEmpty) return;
    final model = result.displayingChildModelMap[widget.index];
    if (model == null) {
      picAlignmentX.value = 0;
      return;
    }

    picAlignmentX.value = 1 - model.displayPercentage;
    if (model.leadingMarginToViewport > 0) {
      picAlignmentX.value = -picAlignmentX.value;
    }

    if (picAlignmentX.value > 1) {
      picAlignmentX.value = 1;
    } else if (picAlignmentX.value < -1) {
      picAlignmentX.value = -1;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget resultWidget = Stack(
      alignment: AlignmentDirectional.center,
      children: [
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          bottom: 0,
          child: _buildPageItemBgPicView(widget.index),
        ),
        const SizedBox.expand(),
        _buildNum(widget.index),
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
      valueListenable: picAlignmentX,
      builder: (BuildContext context, double alignmentX, Widget? child) {
        return Image.network(
          widget.imgUrl,
          fit: BoxFit.cover,
          alignment: Alignment(alignmentX, 0),
        );
      },
    );
  }
}
