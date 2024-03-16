/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/fluttercandies/flutter_scrollview_observer
 * @Date: 2024-03-11 21:08:23
 */

import 'package:flutter/material.dart';
import 'package:scrollview_observer/scrollview_observer.dart';
import 'package:scrollview_observer_example/utils/snackbar.dart';

class CustomScrollViewCenterDemoPage extends StatefulWidget {
  const CustomScrollViewCenterDemoPage({Key? key}) : super(key: key);

  @override
  State<CustomScrollViewCenterDemoPage> createState() =>
      _CustomScrollViewCenterDemoPageState();
}

class _CustomScrollViewCenterDemoPageState
    extends State<CustomScrollViewCenterDemoPage> {
  BuildContext? _sliverListCtx1;
  BuildContext? _sliverListCtx2;
  BuildContext? _sliverListCtx3;
  BuildContext? _sliverListCtx4;
  final _centerKey = GlobalKey();
  ScrollController scrollController = ScrollController();

  late SliverObserverController observerController;

  @override
  void initState() {
    super.initState();
    observerController = SliverObserverController(controller: scrollController)
      ..cacheJumpIndexOffset = false;
  }

  @override
  void dispose() {
    observerController.controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("CustomScrollView - center")),
      body: SliverViewObserver(
        controller: observerController,
        child: _buildScrollView(),
        sliverContexts: () {
          return [
            if (_sliverListCtx1 != null) _sliverListCtx1!,
            if (_sliverListCtx2 != null) _sliverListCtx2!,
            if (_sliverListCtx3 != null) _sliverListCtx3!,
            if (_sliverListCtx4 != null) _sliverListCtx4!,
          ];
        },
        onObserveAll: (resultMap) {
          final model1 = resultMap[_sliverListCtx1];
          if (model1 != null &&
              model1.visible &&
              model1 is ListViewObserveModel) {
            debugPrint('1 visible -- ${model1.visible}');
            debugPrint('1 firstChild.index -- ${model1.firstChild?.index}');
            debugPrint('1 displaying -- ${model1.displayingChildIndexList}');
          }
          final model2 = resultMap[_sliverListCtx2];
          if (model2 != null &&
              model2.visible &&
              model2 is ListViewObserveModel) {
            debugPrint('2 visible -- ${model2.visible}');
            debugPrint('2 firstChild.index -- ${model2.firstChild?.index}');
            debugPrint('2 displaying -- ${model2.displayingChildIndexList}');
          }
          final model3 = resultMap[_sliverListCtx3];
          if (model3 != null &&
              model3.visible &&
              model3 is ListViewObserveModel) {
            debugPrint('3 visible -- ${model3.visible}');
            debugPrint('3 firstChild.index -- ${model3.firstChild?.index}');
            debugPrint('3 displaying -- ${model3.displayingChildIndexList}');
          }
          final model4 = resultMap[_sliverListCtx4];
          if (model4 != null &&
              model4.visible &&
              model4 is ListViewObserveModel) {
            debugPrint('4 visible -- ${model4.visible}');
            debugPrint('4 firstChild.index -- ${model4.firstChild?.index}');
            debugPrint('4 displaying -- ${model4.displayingChildIndexList}');
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
                SnackBarUtil.showSnackBar(
                  context: context,
                  text: 'SliverList - Jumping to row 29',
                );
                observerController.animateTo(
                  sliverContext: _sliverListCtx1,
                  index: 29,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              icon: const Icon(Icons.ac_unit_outlined),
            ),
            IconButton(
              onPressed: () {
                SnackBarUtil.showSnackBar(
                  context: context,
                  text: '_sliverListCtx2 - Jumping to item 20',
                );
                observerController.animateTo(
                  sliverContext: _sliverListCtx2,
                  index: 20,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              icon: const Icon(Icons.backup_table),
            ),
            IconButton(
              onPressed: () {
                SnackBarUtil.showSnackBar(
                  context: context,
                  text: '_sliverListCtx3 - Jumping to item 20',
                );
                observerController.animateTo(
                  sliverContext: _sliverListCtx3,
                  index: 20,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  alignment: 1,
                );
              },
              icon: const Icon(Icons.cabin),
            ),
            IconButton(
              onPressed: () {
                SnackBarUtil.showSnackBar(
                  context: context,
                  text: '_sliverListCtx4 - Jumping to item 20',
                );
                observerController.animateTo(
                  sliverContext: _sliverListCtx4,
                  index: 20,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  alignment: 1,
                );
              },
              icon: const Icon(Icons.cruelty_free),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScrollView() {
    return CustomScrollView(
      center: _centerKey,
      anchor: 1,
      controller: scrollController,
      slivers: [
        _buildSliverListView(
          color: Colors.redAccent,
          onBuild: (ctx) {
            _sliverListCtx1 = ctx;
          },
        ),
        _buildSliverListView(
          color: Colors.blueGrey,
          onBuild: (ctx) {
            _sliverListCtx2 = ctx;
          },
        ),
        SliverPadding(padding: EdgeInsets.zero, key: _centerKey),
        _buildSliverListView(
          color: Colors.teal,
          onBuild: (ctx) {
            _sliverListCtx3 = ctx;
          },
        ),
        _buildSliverListView(
          color: Colors.purple,
          onBuild: (ctx) {
            _sliverListCtx4 = ctx;
          },
        ),
      ],
    );
  }

  Widget _buildSliverListView({
    required Color color,
    Function(BuildContext)? onBuild,
  }) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (ctx, index) {
          onBuild?.call(ctx);
          final int itemIndex = index ~/ 2;
          return Container(
            height: (itemIndex % 2 == 0) ? 80 : 50,
            color: color,
            child: Center(
              child: Text(
                "index -- $index",
                style: const TextStyle(color: Colors.white),
              ),
            ),
          );
        },
        childCount: 100,
      ),
    );
  }
}
