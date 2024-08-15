/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/LinXunFeng/flutter_scrollview_observer
 * @Date: 2023-09-16 19:41:33
 */

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:scrollview_observer/scrollview_observer.dart';
import 'package:scrollview_observer_example/utils/random.dart';

class MultiSliverDemoModel {
  final String tag;
  final List<String> value;

  const MultiSliverDemoModel({
    required this.tag,
    required this.value,
  });
}

class MultiSliverDemoPage extends StatefulWidget {
  const MultiSliverDemoPage({Key? key}) : super(key: key);

  @override
  State<MultiSliverDemoPage> createState() => _MultiSliverDemoPageState();
}

class _MultiSliverDemoPageState extends State<MultiSliverDemoPage> {
  List<MultiSliverDemoModel> modelList = [];

  final appBarKey = GlobalKey();

  final scrollController = ScrollController();
  late final SliverObserverController sliverItemObserverController;
  // late final SliverObserverController sliverObserverController;
  Map<int, BuildContext> itemSliverIndexCtxMap = {};
  Map<int, BuildContext> sliverIndexCtxMap = {};

  ValueNotifier<int> tabCurrentSelectedIndex = ValueNotifier(0);
  bool isIgnoreCalcTabBarIndex = false;

  @override
  void initState() {
    super.initState();
    sliverItemObserverController = SliverObserverController(
      controller: scrollController,
    );
    // sliverObserverController = SliverObserverController(
    //   controller: scrollController,
    // );

    for (var i = 0; i < 4; i++) {
      final tag = 'Section ${i + 1}';
      List<String> values = [];
      for (var j = 0; j < 4; j++) {
        values.add('Row: ${i + 1}-$j');
      }
      modelList.add(MultiSliverDemoModel(tag: tag, value: values));
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget resultWidget = _buildScrollView();
    resultWidget = _buildSliverItemObserver(child: resultWidget);
    resultWidget = _buildSliverObserver(child: resultWidget);
    return Scaffold(
      body: resultWidget,
      bottomNavigationBar: buildBottomNavigationBar(context),
    );
  }

  /// To observe sliver items and handle scrollTo.
  Widget _buildSliverItemObserver({
    required Widget child,
  }) {
    return SliverViewObserver(
      controller: sliverItemObserverController,
      sliverContexts: () => itemSliverIndexCtxMap.values.toList(),
      child: child,
    );
  }

  /// To observe which sliver is currently the first.
  Widget _buildSliverObserver({
    required Widget child,
  }) {
    return SliverViewObserver(
      // controller: sliverObserverController,
      child: child,
      sliverContexts: () => sliverIndexCtxMap.values.toList(),
      triggerOnObserveType: ObserverTriggerOnObserveType.directly,
      dynamicLeadingOffset: () {
        // Accumulate the height of all PersistentHeader.
        return ObserverUtils.calcPersistentHeaderExtent(
              key: appBarKey,
              offset: scrollController.offset,
            ) +
            1; // To avoid tabBar index rebound.
      },
      onObserveViewport: (result) {
        if (isIgnoreCalcTabBarIndex) return;
        int? currentTabIndex;
        final currentFirstSliverCtx = result.firstChild.sliverContext;
        for (var sectionIndex in sliverIndexCtxMap.keys) {
          final ctx = sliverIndexCtxMap[sectionIndex];
          if (ctx == null) continue;
          // If they are not the same sliver, continue.
          if (currentFirstSliverCtx != ctx) continue;
          // If the sliver is not visible, continue.
          final visible =
              (ctx.findRenderObject() as RenderSliver).geometry?.visible ??
                  false;
          if (!visible) continue;
          currentTabIndex = sectionIndex;
          break;
        }
        if (currentTabIndex == null) return;
        updateTabBarIndex(currentTabIndex);
      },
    );
  }

  Widget _buildScrollView() {
    return CustomScrollView(
      controller: scrollController,
      physics: const ClampingScrollPhysics(),
      slivers: [
        SliverAppBar(
          key: appBarKey,
          pinned: true,
          title: const Text('Multi Sliver'),
        ),
        ...List.generate(modelList.length, (mainIndex) {
          return _buildSectionListView(mainIndex);
        }),
      ],
    );
  }

  Widget buildBottomNavigationBar(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: List.generate(modelList.length, (index) {
            return Expanded(
              child: InkWell(
                onTap: () async {
                  updateTabBarIndex(index);
                  isIgnoreCalcTabBarIndex = true;
                  // await sliverItemObserverController.jumpTo(
                  //   sliverContext: itemSliverIndexCtxMap[index],
                  //   index: 0,
                  //   isFixedHeight: true,
                  //   offset: (offset) {
                  //     return ObserverUtils.calcPersistentHeaderExtent(
                  //       key: appBarKey,
                  //       offset: offset,
                  //     );
                  //   },
                  // );
                  await sliverItemObserverController.animateTo(
                    sliverContext: itemSliverIndexCtxMap[index],
                    index: 0,
                    isFixedHeight: true,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    offset: (offset) {
                      return ObserverUtils.calcPersistentHeaderExtent(
                        key: appBarKey,
                        offset: offset,
                      );
                    },
                  );
                  isIgnoreCalcTabBarIndex = false;
                },
                child: ValueListenableBuilder(
                  valueListenable: tabCurrentSelectedIndex,
                  builder: (BuildContext context, int value, Widget? child) {
                    return Container(
                      alignment: Alignment.center,
                      height: 40,
                      decoration: BoxDecoration(
                        border: Border.all(width: 0.5),
                        color: value == index ? Colors.amber : Colors.white,
                      ),
                      child: Text(
                        modelList[index].tag,
                      ),
                    );
                  },
                ),
              ),
            );
          }),
        ),
        SizedBox(height: MediaQuery.paddingOf(context).bottom),
      ],
    );
  }

  Widget _buildSectionListView(int mainIndex) {
    Widget resultWidget = SliverStickyHeader(
      header: Container(
        height: 40,
        color: Colors.white,
        padding: const EdgeInsets.only(left: 12),
        alignment: Alignment.centerLeft,
        child: Text(
          modelList[mainIndex].tag,
        ),
      ),
      sliver: SliverFixedExtentList(
        itemExtent: 120,
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            // Save the context of SliverList.
            itemSliverIndexCtxMap[mainIndex] = context;
            return Container(
              padding: const EdgeInsets.only(left: 12),
              color: RandomTool.color(),
              alignment: Alignment.centerLeft,
              child: Text(
                modelList[mainIndex].value[index],
              ),
            );
          },
          childCount: modelList[mainIndex].value.length,
        ),
      ),
    );
    resultWidget = SliverObserveContext(
      child: resultWidget,
      onObserve: (context) {
        // Save the context of the outermost sliver.
        sliverIndexCtxMap[mainIndex] = context;
      },
    );
    return resultWidget;
  }

  updateTabBarIndex(int index) {
    if (index == tabCurrentSelectedIndex.value) return;
    tabCurrentSelectedIndex.value = index;
  }
}
