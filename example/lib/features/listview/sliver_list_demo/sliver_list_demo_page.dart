/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Reop: https://github.com/LinXunFeng/flutter_scrollview_observer
 * @Date: 2022-08-08 00:20:03
 */
import 'package:flutter/material.dart';
import 'package:scrollview_observer/scrollview_observer.dart';
import 'package:scrollview_observer_example/typedefs.dart';

class SliverListViewDemoPage extends StatefulWidget {
  const SliverListViewDemoPage({Key? key}) : super(key: key);

  @override
  State<SliverListViewDemoPage> createState() => _SliverListViewDemoPageState();
}

class _SliverListViewDemoPageState extends State<SliverListViewDemoPage> {
  BuildContext? _sliverListViewCtx1;

  final GlobalKey _sliverListView2Key = GlobalKey();
  BuildContext? get _sliverListViewCtx2 => _sliverListView2Key.currentContext;

  int _hitIndexForCtx1 = 0;
  int _hitIndexForCtx2 = 0;

  @override
  void initState() {
    super.initState();

    // Trigger an observation manually
    ambiguate(WidgetsBinding.instance)?.addPostFrameCallback((timeStamp) {
      ListViewOnceObserveNotification().dispatch(_sliverListViewCtx1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("SliverListView")),
      body: ListViewObserver(
        child: CustomScrollView(
          slivers: [
            _buildSliverListView1(),
            _buildSliverListView2(),
          ],
        ),
        sliverListContexts: () {
          return [
            if (_sliverListViewCtx1 != null) _sliverListViewCtx1!,
            if (_sliverListViewCtx2 != null) _sliverListViewCtx2!,
          ];
        },
        onObserveAll: (resultMap) {
          final model1 = resultMap[_sliverListViewCtx1];
          if (model1 != null && model1.visible) {
            debugPrint('1 visible -- ${model1.visible}');
            debugPrint('1 firstChild.index -- ${model1.firstChild?.index}');
            debugPrint('1 displaying -- ${model1.displayingChildIndexList}');
            setState(() {
              _hitIndexForCtx1 = model1.firstChild?.index ?? 0;
            });
          }

          final model2 = resultMap[_sliverListViewCtx2];
          if (model2 != null && model2.visible) {
            debugPrint('2 visible -- ${model2.visible}');
            debugPrint('2 firstChild.index -- ${model2.firstChild?.index}');
            debugPrint('2 displaying -- ${model2.displayingChildIndexList}');
            setState(() {
              _hitIndexForCtx2 = model2.firstChild?.index ?? 0;
            });
          }
        },
      ),
    );
  }

  SliverList _buildSliverListView1() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (ctx, index) {
          if (_sliverListViewCtx1 != ctx) {
            _sliverListViewCtx1 = ctx;
          }
          return Container(
            height: (index % 2 == 0) ? 80 : 50,
            color: _hitIndexForCtx1 == index ? Colors.red : Colors.black12,
            child: Center(
              child: Text(
                "index -- $index",
                style: TextStyle(
                  color:
                      _hitIndexForCtx1 == index ? Colors.white : Colors.black,
                ),
              ),
            ),
          );
        },
        childCount: 30,
      ),
    );
  }

  SliverList _buildSliverListView2() {
    return SliverList(
      key: _sliverListView2Key,
      delegate: SliverChildBuilderDelegate(
        (ctx, index) {
          return Container(
            height: (index % 2 == 0) ? 80 : 50,
            color: _hitIndexForCtx2 == index ? Colors.amber : Colors.blue[50],
            child: Center(
              child: Text(
                "index -- $index",
                style: TextStyle(
                  color:
                      _hitIndexForCtx2 == index ? Colors.white : Colors.black,
                ),
              ),
            ),
          );
        },
        childCount: 30,
      ),
    );
  }
}
