/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/LinXunFeng/flutter_scrollview_observer
 * @Date: 2022-08-08 00:20:03
 */
import 'package:flutter/material.dart';
import 'package:scrollview_observer/scrollview_observer.dart';
import 'package:scrollview_observer_example/typedefs.dart';

class ListViewDemoPage extends StatefulWidget {
  const ListViewDemoPage({Key? key}) : super(key: key);

  @override
  State<ListViewDemoPage> createState() => _ListViewDemoPageState();
}

class _ListViewDemoPageState extends State<ListViewDemoPage> {
  int _hitIndex = 0;

  ScrollController scrollController =
      ScrollController(initialScrollOffset: 1000);

  late ListObserverController observerController;

  @override
  void initState() {
    super.initState();

    observerController = ListObserverController(controller: scrollController)
      ..initialIndex = 10;

    // Trigger an observation manually
    ambiguate(WidgetsBinding.instance)?.endOfFrame.then(
      (_) {
        // After layout
        if (mounted) {
          observerController.dispatchOnceObserve();
        }
      },
    );
  }

  @override
  void dispose() {
    observerController.controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("ListView")),
      body: ListViewObserver(
        child: _buildListView(),
        autoTriggerObserveTypes: const [
          ObserverAutoTriggerObserveType.scrollEnd,
        ],
        triggerOnObserveType: ObserverTriggerOnObserveType.directly,
        controller: observerController,
        onObserve: (resultModel) {
          debugPrint('visible -- ${resultModel.visible}');
          debugPrint('firstChild.index -- ${resultModel.firstChild?.index}');
          debugPrint('displaying -- ${resultModel.displayingChildIndexList}');

          for (var item in resultModel.displayingChildModelList) {
            debugPrint(
                'item - ${item.index} - ${item.leadingMarginToViewport} - ${item.trailingMarginToViewport}');
          }

          setState(() {
            _hitIndex = resultModel.firstChild?.index ?? 0;
          });
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.airline_stops_outlined),
        onPressed: () {
          observerController.jumpTo(index: 50);
          // observerController.animateTo(
          //   index: 50,
          //   duration: const Duration(seconds: 1),
          //   curve: Curves.ease,
          // );
        },
      ),
    );
  }

  ListView _buildListView() {
    // return ListView.builder(
    //   itemExtent: 50,
    //   controller: scrollController,
    //   itemCount: 100,
    //   itemBuilder: (context, index) {
    //     return _buildListItemView(index);
    //   },
    // );
    return ListView.separated(
      padding: const EdgeInsets.only(top: 1000, bottom: 1000),
      controller: scrollController,
      itemBuilder: (ctx, index) {
        return _buildListItemView(index);
      },
      separatorBuilder: (ctx, index) {
        return _buildSeparatorView();
      },
      itemCount: 100,
      cacheExtent: double.maxFinite,
    );
  }

  Widget _buildListItemView(int index) {
    return Container(
      height: (index % 2 == 0) ? 80 : 50,
      color: _hitIndex == index ? Colors.red : Colors.black12,
      child: Center(
        child: Text(
          "index -- $index",
          style: TextStyle(
            color: _hitIndex == index ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  Container _buildSeparatorView() {
    return Container(
      color: Colors.white,
      height: 5,
    );
  }
}
