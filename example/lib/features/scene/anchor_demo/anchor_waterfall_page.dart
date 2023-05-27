/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/LinXunFeng/flutter_scrollview_observer
 * @Date: 2023-05-27 11:51:24
 */

import 'package:flutter/material.dart';
import 'package:scrollview_observer/scrollview_observer.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

class AnchorWaterfallPage extends StatefulWidget {
  const AnchorWaterfallPage({Key? key}) : super(key: key);

  @override
  State<AnchorWaterfallPage> createState() => _AnchorWaterfallPageState();
}

class _AnchorWaterfallPageState extends State<AnchorWaterfallPage>
    with SingleTickerProviderStateMixin {
  ScrollController scrollController = ScrollController();

  late GridObserverController observerController;
  late TabController _tabController;
  List tabs = ["News(0)", "History(5)", "Picture(10)"];
  List<int> tabIndexs = [0, 5, 10];

  @override
  void initState() {
    super.initState();
    observerController = GridObserverController(controller: scrollController);
    _tabController = TabController(length: tabs.length, vsync: this);
  }

  @override
  void dispose() {
    observerController.controller?.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Anchor Waterfall"),
        bottom: PreferredSize(
          preferredSize: const Size(double.infinity, 44),
          child: TabBar(
            controller: _tabController,
            tabs: tabs.map((e) => Tab(text: e)).toList(),
            onTap: (index) {
              observerController.animateTo(
                index: tabIndexs[index],
                duration: const Duration(milliseconds: 250),
                curve: Curves.ease,
              );
            },
          ),
        ),
      ),
      body: GridViewObserver(
        child: _buildGridView(),
        controller: observerController,
        customTargetRenderSliverType: (renderObject) {
          return renderObject is RenderSliverWaterfallFlow;
        },
        onObserve: (resultModel) {
          debugPrint(
              'firstGroupChildIndexList -- ${resultModel.firstGroupChildList.map((e) => e.index).toList()}');
          debugPrint(
              'displayingChildIndexList -- ${resultModel.displayingChildIndexList}');

          _tabController.index = ObserverUtils.calcAnchorTabIndex(
            observeModel: resultModel,
            tabIndexs: tabIndexs,
            currentTabIndex: _tabController.index,
          );
        },
      ),
    );
  }

  Widget _buildGridView() {
    return WaterfallFlow.builder(
      controller: scrollController,
      gridDelegate: const SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 15,
        crossAxisSpacing: 10,
      ),
      itemBuilder: (BuildContext context, int index) {
        return Container(
          alignment: Alignment.center,
          color: Colors.teal[100 * (index % 9)],
          child: Text('grid item $index'),
          height: 50.0 + 100.0 * (index % 9),
        );
      },
      itemCount: 20,
    );
  }
}
