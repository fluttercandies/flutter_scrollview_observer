/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/LinXunFeng/flutter_scrollview_observer
 * @Date: 2022-08-20 09:22:52
 */

import 'package:flutter/material.dart';
import 'package:scrollview_observer/scrollview_observer.dart';
import 'package:scrollview_observer_example/typedefs.dart';

class SliverAppBarDemoPage extends StatefulWidget {
  const SliverAppBarDemoPage({Key? key}) : super(key: key);

  @override
  State<SliverAppBarDemoPage> createState() => _SliverAppBarDemoPageState();
}

class _SliverAppBarDemoPageState extends State<SliverAppBarDemoPage> {
  BuildContext? _sliverListCtx;
  BuildContext? _sliverGridCtx;

  GlobalKey appBarKey = GlobalKey();

  int _hitIndexForCtx1 = 0;
  List<int> _hitIndexsForGrid = [];

  ScrollController scrollController = ScrollController();

  late SliverObserverController observerController;

  @override
  void initState() {
    super.initState();

    observerController = SliverObserverController(controller: scrollController)
      ..initialIndexModelBlock = () {
        return ObserverIndexPositionModel(
          index: 6,
          sliverContext: _sliverListCtx,
          offset: calcPersistentHeaderExtent,
        );
      };

    // Trigger an observation manually
    ambiguate(WidgetsBinding.instance)?.addPostFrameCallback((timeStamp) {
      ListViewOnceObserveNotification().dispatch(_sliverListCtx);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SliverViewObserver(
        controller: observerController,
        child: _buildScrollView(),
        sliverListContexts: () {
          return [
            if (_sliverListCtx != null) _sliverListCtx!,
            if (_sliverGridCtx != null) _sliverGridCtx!,
          ];
        },
        onObserveAll: (resultMap) {
          final model1 = resultMap[_sliverListCtx];
          if (model1 != null &&
              model1.visible &&
              model1 is ListViewObserveModel) {
            debugPrint('1 visible -- ${model1.visible}');
            debugPrint('1 firstChild.index -- ${model1.firstChild?.index}');
            debugPrint('1 displaying -- ${model1.displayingChildIndexList}');
            setState(() {
              _hitIndexForCtx1 = model1.firstChild?.index ?? 0;
            });
          }

          final model2 = resultMap[_sliverGridCtx];
          if (model2 != null &&
              model2.visible &&
              model2 is GridViewObserveModel) {
            debugPrint('2 visible -- ${model2.visible}');
            debugPrint('2 displaying -- ${model2.displayingChildIndexList}');
            setState(() {
              _hitIndexsForGrid =
                  model2.firstGroupChildList.map((e) => e.index).toList();
            });
          }
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              onPressed: () {
                _showSnackBar(
                  context: context,
                  text: 'SliverList - Jumping to row 8',
                );
                observerController.animateTo(
                  sliverContext: _sliverListCtx,
                  index: 8,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  offset: calcPersistentHeaderExtent,
                );
              },
              icon: const Icon(Icons.ac_unit_outlined),
            ),
            IconButton(
              onPressed: () {
                _showSnackBar(
                  context: context,
                  text: 'SliverGrid - Jumping to item 5',
                );
                observerController.animateTo(
                  sliverContext: _sliverGridCtx,
                  index: 5,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  offset: calcPersistentHeaderExtent,
                );
              },
              icon: const Icon(Icons.backup_table),
            ),
          ],
        ),
      ),
    );
  }

  _showSnackBar({
    required BuildContext context,
    required String text,
  }) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        duration: const Duration(milliseconds: 2000),
      ),
    );
  }

  Widget _buildScrollView() {
    return CustomScrollView(
      controller: scrollController,
      // scrollDirection: Axis.horizontal,
      slivers: [
        _buildSliverAppBar(),
        _buildSliverListView(),
        _buildSliverGridView(),
      ],
      cacheExtent: double.maxFinite,
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      key: appBarKey,
      pinned: true,
      expandedHeight: 200,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text('AppBar'),
        background: Container(color: Colors.orange),
      ),
    );
  }

  Widget _buildSliverListView() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (ctx, index) {
          _sliverListCtx ??= ctx;
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
        childCount: 10,
      ),
    );
  }

  Widget _buildSliverGridView() {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, //Grid按两列显示
        mainAxisSpacing: 10.0,
        crossAxisSpacing: 10.0,
        childAspectRatio: 2.0,
      ),
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          _sliverGridCtx ??= context;
          return Container(
            color: (_hitIndexsForGrid.contains(index))
                ? Colors.green
                : Colors.blue[100],
            child: Center(
              child: Text('index -- $index'),
            ),
          );
        },
        childCount: 20,
      ),
    );
  }

  double calcPersistentHeaderExtent(double offset) {
    return ObserverUtils.calcPersistentHeaderExtent(
      key: appBarKey,
      offset: offset,
    );
  }
}
