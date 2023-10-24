/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/LinXunFeng/flutter_scrollview_observer
 * @Date: 2023-05-21 11:14:46
 */
// ignore: implementation_imports
import 'package:extended_list/src/rendering/sliver_grid.dart';
import 'package:flutter/material.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:scrollview_observer/scrollview_observer.dart';

class GridViewCustomDemoPage extends StatefulWidget {
  const GridViewCustomDemoPage({Key? key}) : super(key: key);

  @override
  State<GridViewCustomDemoPage> createState() => _GridViewCustomDemoPageState();
}

class _GridViewCustomDemoPageState extends State<GridViewCustomDemoPage> {
  ScrollController scrollController = ScrollController();

  late GridObserverController observerController;

  @override
  void initState() {
    observerController = GridObserverController(
      controller: scrollController,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Custom')),
      body: GridViewObserver(
        child: _buildGridView(),
        controller: observerController,
        customTargetRenderSliverType: (renderObj) {
          // Here you tell the package what type of RenderObject it needs to observe.
          return renderObj is ExtendedRenderSliverGrid;
        },
        // customHandleObserve: (context) {
        //   // Here you can customize the observation logic.
        //   return ObserverCore.handleGridObserve(
        //     context: context,
        //     fetchLeadingOffset: () => 100,
        //   );
        // },
        onObserve: (resultModel) {
          debugPrint(
              'firstChild.index -- ${resultModel.firstGroupChildList.map((e) => e.index)}');
          debugPrint('displaying -- ${resultModel.displayingChildIndexList}');
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.airline_stops_sharp),
        onPressed: () {
          observerController.jumpTo(
            index: 10,
          );
        },
      ),
    );
  }

  Widget _buildGridView() {
    return LoadingMoreList(
      ListConfig(
        controller: scrollController,
        itemBuilder: (context, item, index) {
          if (scrollController.hasClients &&
              (observerController.sliverContexts.isEmpty ||
                  observerController.sliverContexts.first != context)) {
            observerController.reattach();
          }
          return Container(
            color: Colors.cyan,
            child: ListTile(
              title: Text('index - $index'),
            ),
          );
        },
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 300.0,
          crossAxisSpacing: 3.0,
          mainAxisSpacing: 3.0,
        ),
        sourceList: SourceList(),
      ),
    );
  }
}

class SourceList extends LoadingMoreBase<int> {
  @override
  Future<bool> loadData([bool isloadMoreAction = false]) async {
    await Future.delayed(const Duration(seconds: 2));
    for (var i = 0; i < 30; i++) {
      add(i);
    }
    return true;
  }
}
