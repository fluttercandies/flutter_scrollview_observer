import 'package:flutter/material.dart';
import 'package:scrollview_observer/scrollview_observer.dart';

class VisibilityListViewPage extends StatefulWidget {
  const VisibilityListViewPage({Key? key}) : super(key: key);

  @override
  State<VisibilityListViewPage> createState() => _VisibilityListViewPageState();
}

class _VisibilityListViewPageState extends State<VisibilityListViewPage> {
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
          final models = resultModel.displayingChildModelList;
          final indexList = models.map((e) => e.index).toList();
          final displayPercentageList =
              models.map((e) => e.displayPercentage).toList();
          debugPrint('index -- $indexList -- $displayPercentageList');
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
      height: isEven ? 80 : 50,
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
