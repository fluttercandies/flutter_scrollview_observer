/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/LinXunFeng/flutter_scrollview_observer
 * @Date: 2023-08-25 23:14:20
 */

import 'package:flutter/material.dart';
import 'package:scrollview_observer/scrollview_observer.dart';
import 'package:scrollview_observer_example/features/scene/visibility_demo/mixin/visibility_exposure_mixin.dart';
import 'package:visibility_detector/visibility_detector.dart';

class VisibilityScrollViewPage extends StatefulWidget {
  const VisibilityScrollViewPage({Key? key}) : super(key: key);

  @override
  State<VisibilityScrollViewPage> createState() =>
      _VisibilityScrollViewPageState();
}

class _VisibilityScrollViewPageState extends State<VisibilityScrollViewPage>
    with VisibilityExposureMixin {
  BuildContext? _sliverListCtx;
  BuildContext? _sliverGridCtx;

  int needExposeIndex = 6;

  final observerController = SliverObserverController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SliverViewObserver(
        controller: observerController,
        child: _buildScrollView(),
        sliverContexts: () {
          return [
            if (_sliverListCtx != null) _sliverListCtx!,
            if (_sliverGridCtx != null) _sliverGridCtx!,
          ];
        },
        // autoTriggerObserveTypes: const [
        //   ObserverAutoTriggerObserveType.scrollEnd,
        // ],
        triggerOnObserveType: ObserverTriggerOnObserveType.directly,
        onObserveAll: (resultMap) {
          // SliverList
          final listResultModel = resultMap[_sliverListCtx];
          if (listResultModel != null) {
            handleExposure(
              resultModel: listResultModel,
              recordKeyCallback: (index) => 'list_$index',
              needExposeCallback: (index) {
                // Only the item whose index is 6 needs to calculate whether it
                // has been exposed.
                return index == needExposeIndex; // 6
              },
              toExposeCallback: (index) {
                // Meet the conditions, you can report exposure.
                debugPrint('List Exposure -- $index');
              },
            );
          }

          // SliverGrid
          final gridResultModel = resultMap[_sliverGridCtx];
          if (gridResultModel != null) {
            handleExposure(
              resultModel: gridResultModel,
              recordKeyCallback: (index) => 'grid_$index',
              needExposeCallback: (index) {
                // Only the item whose index is 6 needs to calculate whether it
                // has been exposed.
                return index == needExposeIndex; // 6
              },
              toExposeCallback: (index) {
                // Meet the conditions, you can report exposure.
                debugPrint('Grid Exposure -- $index');
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildScrollView() {
    return CustomScrollView(
      slivers: [
        _buildSliverAppBar(),
        _buildSliverListView(),
        _buildMiddleSliver(),
        _buildSliverGridView(),
      ],
      cacheExtent: double.maxFinite,
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
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
          final isEven = index % 2 == 0;
          final needExpose = index == needExposeIndex;
          return Container(
            height: isEven ? 200 : 100,
            color: needExpose
                ? Colors.purple
                : isEven
                    ? Colors.red
                    : Colors.black12,
            child: Center(
              child: Text(
                "index -- $index",
                style: TextStyle(
                  color: isEven ? Colors.white : Colors.black,
                ),
              ),
            ),
          );
        },
        childCount: 10,
      ),
    );
  }

  Widget _buildMiddleSliver() {
    return SliverVisibilityDetector(
      key: const ValueKey('key'),
      sliver: SliverToBoxAdapter(
        child: Container(
          height: 200,
          color: Colors.blue,
          child: const Center(
            child: Text('Middle Sliver'),
          ),
        ),
      ),
      onVisibilityChanged: (info) {
        // In the scene with PersistentHeader (such as AppBar), the value of
        // [info.visibleFraction] is incorrect.
        debugPrint('visibleFraction: ${info.visibleFraction}');
      },
    );
  }

  Widget _buildSliverGridView() {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10.0,
        crossAxisSpacing: 10.0,
        childAspectRatio: 2.0,
      ),
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          _sliverGridCtx ??= context;

          final needExpose = index == needExposeIndex;

          return Container(
            color: needExpose ? Colors.purple : Colors.green,
            child: Center(
              child: Text(
                'index -- $index',
                style: TextStyle(
                  color: needExpose ? Colors.white : Colors.black,
                ),
              ),
            ),
          );
        },
        childCount: 20,
      ),
    );
  }
}
