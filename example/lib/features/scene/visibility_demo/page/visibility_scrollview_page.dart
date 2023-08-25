import 'package:flutter/material.dart';
import 'package:scrollview_observer/scrollview_observer.dart';
import 'package:visibility_detector/visibility_detector.dart';

class VisibilityScrollViewPage extends StatefulWidget {
  const VisibilityScrollViewPage({Key? key}) : super(key: key);

  @override
  State<VisibilityScrollViewPage> createState() =>
      _VisibilityScrollViewPageState();
}

class _VisibilityScrollViewPageState extends State<VisibilityScrollViewPage> {
  BuildContext? _sliverListCtx;
  BuildContext? _sliverGridCtx;

  ScrollController scrollController = ScrollController();

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
      body: SliverViewObserver(
        controller: observerController,
        child: _buildScrollView(),
        sliverContexts: () {
          return [
            if (_sliverListCtx != null) _sliverListCtx!,
            if (_sliverGridCtx != null) _sliverGridCtx!,
          ];
        },
        autoTriggerObserveTypes: const [
          ObserverAutoTriggerObserveType.scrollEnd,
        ],
        triggerOnObserveType: ObserverTriggerOnObserveType.directly,
        onObserveAll: (resultMap) {
          final model1 = resultMap[_sliverListCtx];

          final model2 = resultMap[_sliverGridCtx];
        },
      ),
    );
  }

  Widget _buildScrollView() {
    return CustomScrollView(
      controller: scrollController,
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
          return Container(
            height: isEven ? 80 : 50,
            color: isEven ? Colors.red : Colors.black12,
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
        childCount: 20,
      ),
    );
  }

  Widget _buildMiddleSliver() {
    return SliverToBoxAdapter(
      child: VisibilityDetector(
        key: const ValueKey('key'),
        onVisibilityChanged: (info) {
          debugPrint('visibleFraction: ${info.visibleFraction}');
        },
        child: Container(
          height: 200,
          color: Colors.blue,
          child: const Center(
            child: Text('Middle Sliver'),
          ),
        ),
      ),
    );
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
        debugPrint('visibleFraction: ${info.visibleFraction}');
      },
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
            color: Colors.green,
            child: Center(
              child: Text('index -- $index'),
            ),
          );
        },
        childCount: 20,
      ),
    );
  }
}
