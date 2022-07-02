import 'package:flutter/material.dart';
import 'package:scrollview_observer/scrollview_observer.dart';

class GridViewDemoPage extends StatefulWidget {
  const GridViewDemoPage({Key? key}) : super(key: key);

  @override
  State<GridViewDemoPage> createState() => _GridViewDemoPageState();
}

class _GridViewDemoPageState extends State<GridViewDemoPage> {
  List<int> _hitIndexs = [0, 1];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("GridView")),
      body: GridViewObserver(
        onObserve: (result) {
          final model = result;
          setState(() {
            _hitIndexs = model.firstGroupChildList.map((e) => e.index).toList();
          });

          print(
              'firstGroupChildList -- ${model.firstGroupChildList.map((e) => e.index)}');
          print('displaying -- ${model.displayingChildIndexList}');
        },
        child: _buildGridView(),
      ),
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.only(top: 1000, bottom: 1000),
      controller: ScrollController(initialScrollOffset: 1000),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 2,
        mainAxisSpacing: 5,
      ),
      itemBuilder: (context, index) {
        return Container(
          color: (_hitIndexs.contains(index)) ? Colors.red : Colors.blue[100],
          child: Center(
            child: Text('index -- $index'),
          ),
        );
      },
      itemCount: 50,
    );
  }
}
