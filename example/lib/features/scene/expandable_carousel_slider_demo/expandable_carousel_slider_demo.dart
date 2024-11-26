/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/fluttercandies/flutter_scrollview_observer
 * @Date: 2024-11-25 20:15:18
 */

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:carousel_slider/utils.dart';
import 'package:collection/collection.dart';

import 'package:scrollview_observer/scrollview_observer.dart';

class ExpandableCarouselSliderDemo extends StatefulWidget {
  const ExpandableCarouselSliderDemo({Key? key}) : super(key: key);

  @override
  State<ExpandableCarouselSliderDemo> createState() =>
      _ExpandableCarouselSliderDemoState();
}

class _ExpandableCarouselSliderDemoState
    extends State<ExpandableCarouselSliderDemo> {
  List<String> imgIdList = [
    'photo-1732282537685-bec9036bf4e0',
    'photo-1732418313819-329bc187bab7',
    'photo-1732135250211-5009233cee37',
    'photo-1731143061417-964b0768bd22',
    'photo-1731949594994-739b3ec954ef',
    'photo-1731773287304-3306a88f1e90',
  ];
  List<double> itemHeightList = [500, 400, 300, 500, 400, 300];
  late ValueNotifier<double> carouselHeight;
  List<Widget> itemWidgetList = [];

  final GlobalKey<CarouselSliderState> _carouselKey =
      GlobalKey<CarouselSliderState>();

  late final observerController = ListObserverController()
    ..observeIntervalForScrolling = const Duration(milliseconds: 1);

  @override
  void initState() {
    super.initState();

    carouselHeight = ValueNotifier(itemHeightList.first);
    itemWidgetList = imgIdList.mapIndexed((index, imgId) {
      return CarouselItem(
        index: index,
        height: itemHeightList[index],
        imgId: imgId,
      );
    }).toList();
  }

  @override
  void dispose() {
    carouselHeight.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expandable Carousel Slider'),
      ),
      body: Column(
        children: [
          _buildCarousel(),
          const SizedBox(height: 20),
          _buildIndicator(),
        ],
      ),
    );
  }

  Widget _buildIndicator() {
    return Container(
      width: 200,
      height: 30,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.all(Radius.circular(15)),
      ),
      child: const Text(
        'I am an indicator',
        style: TextStyle(
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildCarousel() {
    Widget resultWidget = ValueListenableBuilder(
      valueListenable: carouselHeight,
      builder: (context, value, child) {
        return CarouselSlider(
          key: _carouselKey,
          options: CarouselOptions(
            viewportFraction: 1,
            height: carouselHeight.value,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 4),
            onPageChanged: (index, reason) {},
          ),
          items: itemWidgetList,
        );
      },
    );

    resultWidget = ListViewObserver(
      controller: observerController,
      child: resultWidget,
      triggerOnObserveType: ObserverTriggerOnObserveType.directly,
      customTargetRenderSliverType: (renderObj) {
        return renderObj is RenderSliverFillViewport;
      },
      onObserve: (result) {
        final carouselState = _carouselKey.currentState?.carouselState;
        if (carouselState == null) return;
        if (result.displayingChildModelList.length < 2) return;

        final firstChild = result.displayingChildModelList.first;
        final firstChildIndex = firstChild.index;
        // Get the real index of the first child.
        final firstChildRealIndex = getRealIndex(
          firstChildIndex + carouselState.initialPage,
          carouselState.realPage,
          imgIdList.length,
        );
        // Get the real index of the second child.
        int secondChildRealIndex = firstChildRealIndex + 1;
        // Reset to 0 if exceeds the range.
        if (secondChildRealIndex >= imgIdList.length) {
          secondChildRealIndex = 0;
        }

        final firstChildLeadingMarginToViewport =
            firstChild.leadingMarginToViewport;
        final viewportMainAxisExtent = firstChild.viewportMainAxisExtent;
        final firstChildHeight = itemHeightList[firstChildRealIndex];
        final secondChildHeight = itemHeightList[secondChildRealIndex];

        final progress =
            (firstChildLeadingMarginToViewport.abs() / viewportMainAxisExtent)
                .clamp(0.0, 1.0);
        carouselHeight.value = firstChildHeight -
            ((firstChildHeight - secondChildHeight) * progress);
      },
    );
    return resultWidget;
  }
}

class CarouselItem extends StatelessWidget {
  const CarouselItem({
    Key? key,
    required this.index,
    required this.height,
    required this.imgId,
  }) : super(key: key);

  final int index;
  final double height;
  final String imgId;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          child: Container(
            width: double.infinity,
            height: height,
            child: Image.network(
              // 'https://picsum.photos/${MediaQuery.sizeOf(context).width.toInt()}/${height.toInt()}?random=$index',
              'https://images.unsplash.com/$imgId?auto=format&fit=crop&w=${MediaQuery.sizeOf(context).width.toInt()}&h=${height.toInt()}&q=100',
            ),
            color: index % 2 == 0 ? Colors.red : Colors.amber,
          ),
        ),
      ],
    );
  }
}
