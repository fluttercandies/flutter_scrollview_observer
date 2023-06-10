/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/LinXunFeng/flutter_scrollview_observer
 * @Date: 2023-05-14 16:22:36
 */
import 'package:flutter/material.dart';
import 'package:scrollview_observer/scrollview_observer.dart';
import 'package:scrollview_observer_example/features/scene/waterfall_flow_demo/waterfall_flow_grid_item_view.dart';
import 'package:scrollview_observer_example/features/scene/waterfall_flow_demo/waterfall_flow_swipe_view.dart';
import 'package:scrollview_observer_example/features/scene/waterfall_flow_demo/waterfall_flow_type.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

class WaterfallFlowPage extends StatefulWidget {
  const WaterfallFlowPage({Key? key}) : super(key: key);

  @override
  State<WaterfallFlowPage> createState() => WaterfallFlowPageState();
}

class WaterfallFlowPageState extends State<WaterfallFlowPage> {
  BuildContext? grid1Context;
  BuildContext? grid2Context;
  BuildContext? swipeContext;

  BuildContext? firstChildCtxInViewport;
  bool isRemoveSwipe = false;

  int hitIndex = 0;
  WaterFlowHitType hitType = WaterFlowHitType.firstGrid;

  double observeOffset = 150;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Waterfall Flow')),
      body: SliverViewObserver(
        child: _buildBody(),
        leadingOffset: observeOffset,
        autoTriggerObserveTypes: const [
          ObserverAutoTriggerObserveType.scrollEnd,
        ],
        triggerOnObserveType: ObserverTriggerOnObserveType.directly,
        extendedHandleObserve: (context) {
          // An extension of the original observation logic.
          final _obj = ObserverUtils.findRenderObject(context);
          if (_obj is RenderSliverWaterfallFlow) {
            return ObserverCore.handleGridObserve(
              context: context,
              fetchLeadingOffset: () => observeOffset,
            );
          }
          return null;
        },
        // customHandleObserve: (context) {
        //   // Here you can customize the observation logic.
        //   final _obj = ObserverUtils.findRenderObject(context);
        //   if (_obj is RenderSliverList) {
        //     ObserverCore.handleListObserve(context: context);
        //   }
        //   if (_obj is RenderSliverGrid || _obj is RenderSliverWaterfallFlow) {
        //     return ObserverCore.handleGridObserve(context: context);
        //   }
        //   return null;
        // },
        sliverContexts: () {
          return [
            if (grid1Context != null) grid1Context!,
            if (swipeContext != null) swipeContext!,
            if (grid2Context != null) grid2Context!,
          ];
        },
        onObserveViewport: (result) {
          firstChildCtxInViewport = result.firstChild.sliverContext;
          if (firstChildCtxInViewport == grid1Context) {
            debugPrint('current first sliver in viewport - gridView1');
            if (WaterFlowHitType.firstGrid == hitType) return;
            hitType = WaterFlowHitType.firstGrid;
            hitIndex = -1;
          } else if (firstChildCtxInViewport == swipeContext) {
            debugPrint('current first sliver in viewport - swipeView');
            if (WaterFlowHitType.swipe == hitType) return;
            setState(() {
              hitType = WaterFlowHitType.swipe;
            });
          } else if (firstChildCtxInViewport == grid2Context) {
            debugPrint('current first sliver in viewport - gridView2');
            if (WaterFlowHitType.secondGrid == hitType) return;
            hitType = WaterFlowHitType.secondGrid;
            hitIndex = -1;
          }
        },
        onObserveAll: (resultMap) {
          final result = resultMap[firstChildCtxInViewport];
          if (firstChildCtxInViewport == grid1Context) {
            if (WaterFlowHitType.firstGrid != hitType) return;
            if (result == null || result is! GridViewObserveModel) return;
            final firstIndexList = result.firstGroupChildList.map((e) {
              return e.index;
            }).toList();
            handleGridHitIndex(firstIndexList);
          } else if (firstChildCtxInViewport == swipeContext) {
          } else if (firstChildCtxInViewport == grid2Context) {
            if (WaterFlowHitType.secondGrid != hitType) return;
            if (result == null || result is! GridViewObserveModel) return;
            final firstIndexList = result.firstGroupChildList.map((e) {
              return e.index;
            }).toList();
            handleGridHitIndex(firstIndexList);
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.swipe),
        onPressed: () {
          setState(() {
            isRemoveSwipe = !isRemoveSwipe;
          });
        },
      ),
    );
  }

  handleGridHitIndex(List<int> firstIndexList) {
    if (firstIndexList.isEmpty) return;
    debugPrint('grid2Context displaying -- $firstIndexList');
    int targetIndex = firstIndexList.indexOf(hitIndex);
    if (targetIndex == -1) {
      targetIndex = 0;
    } else {
      targetIndex = targetIndex + 1;
      if (targetIndex >= firstIndexList.length) {
        targetIndex = 0;
      }
    }
    setState(() {
      hitIndex = firstIndexList[targetIndex];
    });
  }

  Widget _buildScrollView() {
    return CustomScrollView(
      slivers: [
        _buildSeparator(8),
        _buildGridView(isFirst: true, childCount: 5),
        _buildSeparator(8),
        _buildSwipeView(),
        _buildSeparator(15),
        _buildGridView(isFirst: false, childCount: 20),
      ],
    );
  }

  Widget _buildBody() {
    Widget resultWidget = Stack(
      children: [
        _buildScrollView(),
        Positioned(
          left: 0,
          right: 0,
          height: 1,
          top: observeOffset,
          child: Container(color: Colors.red),
        ),
      ],
    );
    return resultWidget;
  }

  Widget _buildGridView({
    bool isFirst = false,
    required int childCount,
  }) {
    return SliverWaterfallFlow(
      gridDelegate: const SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 15,
        crossAxisSpacing: 10,
      ),
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          WaterFlowHitType selfType;
          if (isFirst) {
            if (grid1Context != context) grid1Context = context;
            selfType = WaterFlowHitType.firstGrid;
          } else {
            if (grid2Context != context) grid2Context = context;
            selfType = WaterFlowHitType.secondGrid;
          }
          return WaterfallFlowGridItemView(
            selfIndex: index,
            selfType: selfType,
            hitIndex: hitIndex,
            hitType: hitType,
          );
        },
        childCount: childCount,
      ),
    );
  }

  Widget _buildSwipeView() {
    if (isRemoveSwipe) return const SliverToBoxAdapter(child: SizedBox());
    return SliverLayoutBuilder(
      builder: (context, _) {
        if (swipeContext != context) swipeContext = context;
        return WaterfallFlowSwipeView(hitType: hitType);
      },
    );
  }

  Widget _buildSeparator(double size) {
    return SliverToBoxAdapter(
      child: Container(height: size),
    );
  }
}
