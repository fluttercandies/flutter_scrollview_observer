/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/LinXunFeng/flutter_scrollview_observer
 * @Date: 2023-05-14 16:22:36
 */
import 'package:flutter/material.dart';
import 'package:scrollview_observer/scrollview_observer.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

class WaterfallFlowPage extends StatefulWidget {
  const WaterfallFlowPage({Key? key}) : super(key: key);

  @override
  State<WaterfallFlowPage> createState() => WaterfallFlowPageState();
}

class WaterfallFlowPageState extends State<WaterfallFlowPage> {
  PageController pageController = PageController(viewportFraction: 0.9);
  BuildContext? grid1Context;
  BuildContext? grid2Context;
  BuildContext? swipeContext;
  BuildContext? bottomDetector;

  BuildContext? firstChildCtxInViewport;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Waterfall Flow')),
      body: SliverViewObserver(
        child: _buildScrollView(),
        autoTriggerObserveTypes: const [
          ObserverAutoTriggerObserveType.scrollEnd,
        ],
        triggerOnObserveType: ObserverTriggerOnObserveType.directly,
        extendedHandleObserve: (context) {
          // An extension of the original observation logic.
          final _obj = context.findRenderObject();
          if (_obj is RenderSliverWaterfallFlow) {
            return ObserverCore.handleGridObserve(context: context);
          }
          return null;
        },
        // customHandleObserve: (context) {
        //   // Here you can customize the observation logic.
        //   final _obj = context.findRenderObject();
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
            if (bottomDetector != null) bottomDetector!,
            if (grid2Context != null) grid2Context!,
          ];
        },
        onObserveViewport: (result) {
          firstChildCtxInViewport = result.firstChild.sliverContext;
          if (firstChildCtxInViewport == grid1Context) {
            debugPrint('current first sliver in viewport - gridView1');
          } else if (firstChildCtxInViewport == swipeContext) {
            debugPrint('current first sliver in viewport - swipeView');
          } else if (firstChildCtxInViewport == grid2Context) {
            debugPrint('current first sliver in viewport - gridView2');
          }
          final displayingChildCtxs =
              result.displayingChildModelList.map((e) => e.sliverContext);

          debugPrint(
              'displayingChildCtxs contains bottomDetector - ${displayingChildCtxs.contains(bottomDetector)}');
        },
        onObserveAll: (resultMap) {
          final result = resultMap[firstChildCtxInViewport];
          if (firstChildCtxInViewport == grid1Context) {
            if (result != null && result is GridViewObserveModel) {
              debugPrint(
                  'grid1Context displaying -- ${result.firstGroupChildList.map((e) {
                return e.index;
              }).toList()}');
            }
          } else if (firstChildCtxInViewport == swipeContext) {
          } else if (firstChildCtxInViewport == grid2Context) {
            if (result != null && result is GridViewObserveModel) {
              debugPrint(
                  'grid2Context displaying -- ${result.firstGroupChildList.map((e) {
                return e.index;
              }).toList()}');
            }
          }
        },
      ),
    );
  }

  Widget _buildScrollView() {
    return CustomScrollView(
      slivers: [
        _buildSeparator(8),
        _buildGridView(isFirst: true, childCount: 5),
        _buildSeparator(8),
        _buildSwipeView(),
        _buildSeparator(15),
        _buildBottomDetector(),
        _buildGridView(isFirst: false, childCount: 20),
      ],
    );
  }

  Widget _buildBottomDetector() {
    return SliverLayoutBuilder(
      builder: (ctx, _) {
        if (bottomDetector != ctx) {
          bottomDetector = ctx;
        }
        return SliverToBoxAdapter(
          child: Container(
            height: 10,
            color: Colors.red,
          ),
        );
      },
    );
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
          if (isFirst) {
            if (grid1Context != context) grid1Context = context;
          } else {
            if (grid2Context != context) grid2Context = context;
          }
          return Container(
            alignment: Alignment.center,
            color: Colors.teal[100 * (index % 9)],
            child: Text('grid item $index'),
            height: 50.0 + 100.0 * (index % 9),
          );
        },
        childCount: childCount,
      ),
    );
  }

  Widget _buildSwipeView() {
    return SliverLayoutBuilder(
      builder: (context, _) {
        if (swipeContext != context) swipeContext = context;
        Widget resultWidget = PageView.builder(
          controller: pageController,
          padEnds: true,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Container(
                color: Colors.blue,
              ),
            );
          },
        );
        resultWidget = SizedBox(height: 200, child: resultWidget);

        resultWidget = SliverToBoxAdapter(child: resultWidget);
        return resultWidget;
      },
    );
  }

  Widget _buildSeparator(double size) {
    return SliverToBoxAdapter(
      child: Container(height: size),
    );
  }
}
