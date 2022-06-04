import 'package:flutter/material.dart';
import 'package:scrollview_observer/scrollview_observer.dart';

class GridViewDemoPage extends StatefulWidget {
  const GridViewDemoPage({Key? key}) : super(key: key);

  @override
  State<GridViewDemoPage> createState() => _GridViewDemoPageState();
}

class _GridViewDemoPageState extends State<GridViewDemoPage> {
  BuildContext? _sliverGridViewContext;

  List<int> _hitIndexs = [];

  @override
  void initState() {
    super.initState();

    // Trigger an observation manually
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      GridViewOnceObserveNotification().dispatch(_sliverGridViewContext);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("GridView")),
      body: GridViewObserver(
        sliverGridContexts: () {
          return [if (_sliverGridViewContext != null) _sliverGridViewContext!];
        },
        onObserve: (resultMap) {
          final model = resultMap[_sliverGridViewContext];
          if (model == null) return;
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
      // gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
      //   maxCrossAxisExtent: 140.0,
      //   childAspectRatio: 0.6,
      //   crossAxisSpacing: 2,
      //   mainAxisSpacing: 5,
      // ),
      itemBuilder: (context, index) {
        if (_sliverGridViewContext != context) {
          _sliverGridViewContext = context;
        }
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
