/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/LinXunFeng/flutter_scrollview_observer
 * @Date: 2023-08-25 23:14:20
 */

import 'package:flutter/material.dart';
import 'package:scrollview_observer/scrollview_observer.dart';
import 'package:scrollview_observer_example/features/scene/visibility_demo/mixin/visibility_exposure_mixin.dart';

class VisibilityListViewPage extends StatefulWidget {
  const VisibilityListViewPage({Key? key}) : super(key: key);

  @override
  State<VisibilityListViewPage> createState() => _VisibilityListViewPageState();
}

class _VisibilityListViewPageState extends State<VisibilityListViewPage>
    with VisibilityExposureMixin {
  final observerController = ListObserverController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Visibility ListView")),
      body: ListViewObserver(
        child: _buildListView(),
        triggerOnObserveType: ObserverTriggerOnObserveType.directly,
        controller: observerController,
        onObserve: (resultModel) {
          // final models = resultModel.displayingChildModelList;
          // final indexList = models.map((e) => e.index).toList();
          // final displayPercentageList =
          //     models.map((e) => e.displayPercentage).toList();
          // debugPrint('index -- $indexList -- $displayPercentageList');

          handleExposure(
            resultModel: resultModel,
            needExposeCallback: (index) {
              // Only the item whose index is 6 needs to calculate whether it
              // has been exposed.
              return index == 6;
            },
            toExposeCallback: (index) {
              // Meet the conditions, you can report exposure.
              debugPrint('Exposure -- $index');
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Trigger an observation manually
          observerController.dispatchOnceObserve();
        },
      ),
    );
  }

  Widget _buildListView() {
    return ListView.separated(
      itemBuilder: (ctx, index) {
        return _buildListItemView(index);
      },
      separatorBuilder: (ctx, index) {
        return _buildSeparatorView();
      },
      itemCount: 100,
    );
  }

  Widget _buildListItemView(int index) {
    final isEven = index % 2 == 0;
    return Container(
      height: isEven ? 200 : 100,
      color: isEven ? Colors.orange[300] : Colors.black12,
      child: Center(
        child: Text(
          "index -- $index",
          style: TextStyle(
            color: isEven ? Colors.white : Colors.black,
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
