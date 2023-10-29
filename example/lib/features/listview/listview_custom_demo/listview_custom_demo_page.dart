/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/LinXunFeng/flutter_scrollview_observer
 * @Date: 2023-05-21 10:31:44
 */
// ignore: implementation_imports
import 'package:extended_list/src/rendering/sliver_list.dart';
import 'package:flutter/material.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:scrollview_observer/scrollview_observer.dart';
import 'package:scrollview_observer_example/utils/snackbar.dart';

class ListViewCustomDemoPage extends StatefulWidget {
  const ListViewCustomDemoPage({Key? key}) : super(key: key);

  @override
  State<ListViewCustomDemoPage> createState() => _ListViewCustomDemoPageState();
}

class _ListViewCustomDemoPageState extends State<ListViewCustomDemoPage> {
  ScrollController scrollController = ScrollController();

  late ListObserverController observerController;

  @override
  void initState() {
    observerController = ListObserverController(
      controller: scrollController,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Custom')),
      body: ListViewObserver(
        child: _buildListView(),
        controller: observerController,
        customTargetRenderSliverType: (renderObj) {
          // Here you tell the package what type of RenderObject it needs to observe.
          return renderObj is ExtendedRenderSliverList;
        },
        // customHandleObserve: (context) {
        //   // Here you can customize the observation logic.
        //   return ObserverCore.handleListObserve(
        //     context: context,
        //     fetchLeadingOffset: () => 100,
        //   );
        // },
        onObserve: (resultModel) {
          debugPrint('firstChild.index -- ${resultModel.firstChild?.index}');
          debugPrint('displaying -- ${resultModel.displayingChildIndexList}');
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.airline_stops_sharp),
        onPressed: () {
          SnackBarUtil.showSnackBar(
            context: context,
            text: 'Jump to row 10',
          );
          observerController.jumpTo(
            index: 10,
            isFixedHeight: true,
          );
        },
      ),
    );
  }

  Widget _buildListView() {
    return LoadingMoreList(
      ListConfig(
        controller: scrollController,
        itemBuilder: (context, item, index) {
          if (scrollController.hasClients &&
              (observerController.sliverContexts.isEmpty ||
                  observerController.sliverContexts.first != context)) {
            observerController.reattach();
          }
          return ListTile(
            title: Text('index - $index'),
          );
        },
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
