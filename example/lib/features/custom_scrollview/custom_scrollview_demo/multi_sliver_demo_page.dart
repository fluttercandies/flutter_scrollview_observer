/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/LinXunFeng/flutter_scrollview_observer
 * @Date: 2023-09-16 19:41:33
 */

import 'package:flutter/material.dart';
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
  late final SliverObserverController sliverObserverController;
  List<BuildContext> contextList = [];

  @override
  void initState() {
    super.initState();
    sliverObserverController = SliverObserverController(
      controller: scrollController,
    );

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
    return Scaffold(
      body: SliverViewObserver(
        controller: sliverObserverController,
        sliverContexts: () => contextList,
        child: CustomScrollView(
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
        ),
      ),
      bottomNavigationBar: buildBottomNavigationBar(context),
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
                onTap: () {
                  // sliverObserverController.jumpTo(
                  //   sliverContext: contextList[index],
                  //   index: 0,
                  //   isFixedHeight: true,
                  //   offset: (offset) {
                  //     return ObserverUtils.calcPersistentHeaderExtent(
                  //       key: appBarKey,
                  //       offset: offset,
                  //     );
                  //   },
                  // );
                  sliverObserverController.animateTo(
                    sliverContext: contextList[index],
                    index: 0,
                    isFixedHeight: true,
                    duration: const Duration(seconds: 1),
                    curve: Curves.easeInOut,
                    offset: (offset) {
                      return ObserverUtils.calcPersistentHeaderExtent(
                        key: appBarKey,
                        offset: offset,
                      );
                    },
                  );
                },
                child: Container(
                  alignment: Alignment.center,
                  height: 40,
                  decoration: BoxDecoration(
                    border: Border.all(width: 0.5),
                  ),
                  child: Text(
                    modelList[index].tag,
                  ),
                ),
              ),
            );
          }),
        ),
        SizedBox(height: MediaQuery.of(context).padding.bottom),
      ],
    );
  }

  Widget _buildSectionListView(int mainIndex) {
    return SliverStickyHeader(
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
            if (contextList.length < mainIndex + 1) {
              contextList.add(context);
            }
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
  }
}
