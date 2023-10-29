/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/fluttercandies/flutter_scrollview_observer
 * @Date: 2023-10-25 21:29:37
 */

import 'package:flutter/material.dart';
import 'package:scrollview_observer/scrollview_observer.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

class WaterfallFlowFixedHeightPage extends StatefulWidget {
  const WaterfallFlowFixedHeightPage({Key? key}) : super(key: key);

  @override
  State<WaterfallFlowFixedHeightPage> createState() =>
      WaterfallFlowFixedHeightPageState();
}

class WaterfallFlowFixedHeightPageState
    extends State<WaterfallFlowFixedHeightPage> {
  BuildContext? grid1Context;

  BuildContext? firstChildCtxInViewport;

  ScrollController scrollController = ScrollController(initialScrollOffset: 0);

  late SliverObserverController observerController;

  @override
  void initState() {
    super.initState();

    observerController = SliverObserverController(controller: scrollController);
  }

  @override
  void dispose() {
    observerController.controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Waterfall Flow')),
      body: SliverViewObserver(
        child: _buildBody(),
        controller: observerController,
        autoTriggerObserveTypes: const [
          ObserverAutoTriggerObserveType.scrollEnd,
        ],
        triggerOnObserveType: ObserverTriggerOnObserveType.directly,
        // extendedHandleObserve: (context) {
        //   // An extension of the original observation logic.
        //   final _obj = ObserverUtils.findRenderObject(context);
        //   if (_obj is RenderSliverWaterfallFlow) {
        //     return ObserverCore.handleGridObserve(
        //       context: context,
        //       fetchLeadingOffset: () => observeOffset,
        //     );
        //   }
        //   return null;
        // },
        sliverContexts: () {
          return [
            if (grid1Context != null) grid1Context!,
          ];
        },
        onObserveViewport: (result) {
          firstChildCtxInViewport = result.firstChild.sliverContext;
          debugPrint(
              'current first sliver in viewport - $firstChildCtxInViewport');
        },
        onObserveAll: (resultMap) {
          final result = resultMap[firstChildCtxInViewport];
          debugPrint('all Observe for current first sliver - $result');
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.airline_stops_outlined),
        onPressed: () {
          observerController.jumpTo(
            index: 13,
            isFixedHeight: true,
            renderSliverType: ObserverRenderSliverType.grid,
          );
        },
      ),
    );
  }

  Widget _buildBody() {
    return CustomScrollView(
      controller: scrollController,
      slivers: [
        _buildGridView(childCount: 50),
      ],
    );
  }

  Widget _buildGridView({
    required int childCount,
  }) {
    return SliverWaterfallFlow(
      gridDelegate: const SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 15,
        crossAxisSpacing: 10,
      ),
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          if (grid1Context != context) grid1Context = context;
          return Container(
            height: 50,
            color: Colors.primaries[index % Colors.primaries.length],
            alignment: Alignment.topLeft,
            child: Text(
              'item: $index',
              style: const TextStyle(fontSize: 20, color: Colors.white),
            ),
          );
        },
        childCount: childCount,
      ),
    );
  }
}
