import 'package:flutter/material.dart';
import 'package:scrollview_observer/scrollview_observer.dart';

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
        onObserve: (resultMap) {
          final model1 = resultMap[_sliverListViewCtx1];
          if (model1 != null) {
            print('1 firstChild.index -- ${model1.firstChild.index}');
            print('1 showing -- ${model1.showingChildIndexList}');
            setState(() {
              _hitIndexForCtx1 = model1.firstChild.index;
            });
          }

          final model2 = resultMap[_sliverListViewCtx2];
          if (model2 != null) {
            print('2 firstChild.index -- ${model2.firstChild.index}');
            print('2 showing -- ${model2.showingChildIndexList}');
            setState(() {
              _hitIndexForCtx2 = model2.firstChild.index;
            });
          }
        },
      ),
      // body: _buildSliverListView(),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          ListViewOnceObserveNotification().dispatch(_sliverListViewCtx1);
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
                color: _hitIndexForCtx1 == index ? Colors.white : Colors.black,
              ),
            ),
          ),
        );
        ;
      },
      childCount: 30,
    ));
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
            ;
          },
          childCount: 30,
        ));
  }
}
