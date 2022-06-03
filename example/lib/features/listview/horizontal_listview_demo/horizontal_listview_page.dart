import 'package:flutter/material.dart';
import 'package:scrollview_observer/scrollview_observer.dart';

class HorizontalListViewPage extends StatefulWidget {
  const HorizontalListViewPage({Key? key}) : super(key: key);

  @override
  State<HorizontalListViewPage> createState() => _HorizontalListViewPageState();
}

class _HorizontalListViewPageState extends State<HorizontalListViewPage> {
  BuildContext? _sliverListViewContext;

  int _hitIndex = 0;

  @override
  void initState() {
    super.initState();

    // Trigger an observation manually
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      ListViewOnceObserveNotification().dispatch(_sliverListViewContext);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("ListView")),
      body: ListViewObserver(
        child: _buildListView(),
        sliverListContexts: () {
          return [if (_sliverListViewContext != null) _sliverListViewContext!];
        },
        onObserve: (resultMap) {
          final model = resultMap[_sliverListViewContext];
          if (model == null) return;

          print('firstChild.index -- ${model.firstChild.index}');
          print('displaying -- ${model.displayingChildIndexList}');
          setState(() {
            _hitIndex = model.firstChild.index;
          });
        },
      ),
    );
  }

  ListView _buildListView() {
    return ListView.separated(
      itemBuilder: (ctx, index) {
        if (_sliverListViewContext != ctx) {
          _sliverListViewContext = ctx;
        }
        return _buildListItemView(index);
      },
      separatorBuilder: (ctx, index) {
        return _buildSeparatorView();
      },
      itemCount: 50,
      scrollDirection: Axis.horizontal,
    );
  }

  Widget _buildListItemView(int index) {
    return Container(
      width: (index % 2 == 0) ? 180 : 150,
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
      width: 5,
    );
  }
}
