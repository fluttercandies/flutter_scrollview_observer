import 'package:flutter/material.dart';
import 'package:scrollview_observer/scrollview_observer.dart';

class SliverGridViewDemoPage extends StatefulWidget {
  const SliverGridViewDemoPage({Key? key}) : super(key: key);

  @override
  State<SliverGridViewDemoPage> createState() => _SliverGridViewDemoPageState();
}

class _SliverGridViewDemoPageState extends State<SliverGridViewDemoPage> {
  BuildContext? _sliverGridViewContext1;
  BuildContext? _sliverGridViewContext2;

  List<int> _hitIndexs1 = [];
  List<int> _hitIndexs2 = [];

  @override
  void initState() {
    super.initState();

    // Trigger an observation manually
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      GridViewOnceObserveNotification().dispatch(_sliverGridViewContext1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("GridView")),
      body: GridViewObserver(
        sliverGridContexts: () {
          return [
            if (_sliverGridViewContext1 != null) _sliverGridViewContext1!,
            if (_sliverGridViewContext2 != null) _sliverGridViewContext2!
          ];
        },
        onObserve: (resultMap) {
          final model1 = resultMap[_sliverGridViewContext1];
          if (model1 != null && model1.visible) {
            setState(() {
              _hitIndexs1 =
                  model1.firstGroupChildList.map((e) => e.index).toList();
            });

            print(
                '1 -- firstGroupChildList -- ${model1.firstGroupChildList.map((e) => e.index)}');
            print('1 -- displaying -- ${model1.displayingChildIndexList}');
          }

          final model2 = resultMap[_sliverGridViewContext2];
          if (model2 != null && model2.visible) {
            setState(() {
              _hitIndexs2 =
                  model2.firstGroupChildList.map((e) => e.index).toList();
            });

            print(
                '2 -- firstGroupChildList -- ${model2.firstGroupChildList.map((e) => e.index)}');
            print('2 -- displaying -- ${model2.displayingChildIndexList}');
          }
        },
        child: _buildGridView(),
      ),
    );
  }

  Widget _buildGridView() {
    return CustomScrollView(
      slivers: [
        _buildSliverGridView1(),
        _buildSliverGridView2(),
      ],
    );
  }

  Widget _buildSliverGridView1() {
    return SliverGrid(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (_sliverGridViewContext1 != context) {
            _sliverGridViewContext1 = context;
          }
          return Container(
            color:
                (_hitIndexs1.contains(index)) ? Colors.red : Colors.blue[100],
            child: Center(
              child: Text('index -- $index'),
            ),
          );
        },
        childCount: 50,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 2,
        mainAxisSpacing: 5,
      ),
    );
  }

  Widget _buildSliverGridView2() {
    return SliverGrid(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (_sliverGridViewContext2 != context) {
            _sliverGridViewContext2 = context;
          }
          return Container(
            color:
                (_hitIndexs2.contains(index)) ? Colors.red : Colors.blue[100],
            child: Center(
              child: Text('index -- $index'),
            ),
          );
        },
        childCount: 50,
      ),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 140.0,
        childAspectRatio: 0.6,
        crossAxisSpacing: 2,
        mainAxisSpacing: 5,
      ),
    );
  }
}
