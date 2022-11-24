/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/LinXunFeng/flutter_scrollview_observer
 * @Date: 2022-08-08 00:20:03
 */
import 'package:flutter/material.dart';
import 'package:scrollview_observer/scrollview_observer.dart';
import 'package:scrollview_observer_example/typedefs.dart';

class GridViewCtxDemoPage extends StatefulWidget {
  const GridViewCtxDemoPage({Key? key}) : super(key: key);

  @override
  State<GridViewCtxDemoPage> createState() => _GridViewCtxDemoPageState();
}

class _GridViewCtxDemoPageState extends State<GridViewCtxDemoPage> {
  BuildContext? _sliverGridViewContext;

  List<int> _hitIndexs = [];

  @override
  void initState() {
    super.initState();

    // Trigger an observation manually
    ambiguate(WidgetsBinding.instance)?.addPostFrameCallback((timeStamp) {
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
        onObserveAll: (resultMap) {
          final model = resultMap[_sliverGridViewContext];
          if (model == null) return;
          setState(() {
            _hitIndexs = model.firstGroupChildList.map((e) => e.index).toList();
          });

          debugPrint(
              'firstGroupChildList -- ${model.firstGroupChildList.map((e) => e.index)}');
          debugPrint('displaying -- ${model.displayingChildIndexList}');
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
