/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/LinXunFeng/flutter_scrollview_observer
 * @Date: 2022-08-08 00:20:03
 */
import 'package:flutter/material.dart';
import 'package:scrollview_observer/scrollview_observer.dart';
import 'package:scrollview_observer_example/typedefs.dart';

class HorizontalGridViewDemoPage extends StatefulWidget {
  const HorizontalGridViewDemoPage({Key? key}) : super(key: key);

  @override
  State<HorizontalGridViewDemoPage> createState() =>
      _HorizontalGridViewDemoPageState();
}

class _HorizontalGridViewDemoPageState
    extends State<HorizontalGridViewDemoPage> {
  static const double _leadingPadding = 1000;
  BuildContext? _sliverGridViewContext;

  List<int> _hitIndexs = [];

  ScrollController scrollController =
      ScrollController(initialScrollOffset: _leadingPadding);

  late GridObserverController observerController;

  @override
  void initState() {
    super.initState();
    observerController = GridObserverController(controller: scrollController)
      ..initialIndex = 32;

    // Trigger an observation manually
    ambiguate(WidgetsBinding.instance)?.addPostFrameCallback((timeStamp) {
      GridViewOnceObserveNotification().dispatch(_sliverGridViewContext);
    });
  }

  @override
  void dispose() {
    observerController.controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("GridView")),
      body: GridViewObserver(
        controller: observerController,
        sliverGridContexts: () {
          return [if (_sliverGridViewContext != null) _sliverGridViewContext!];
        },
        autoTriggerObserveTypes: const [
          ObserverAutoTriggerObserveType.scrollEnd,
        ],
        triggerOnObserveType:
            ObserverTriggerOnObserveType.displayingItemsChange,
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
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.airline_stops_outlined),
        onPressed: () {
          if (_sliverGridViewContext != null) {
            observerController.jumpTo(
              index: 87,
              sliverContext: _sliverGridViewContext,
            );
          }
          // observerController.jumpTo(
          //   index: 87,
          // );
          // observerController.animateTo(
          //   index: 49,
          //   duration: const Duration(seconds: 1),
          //   curve: Curves.ease,
          // );
        },
      ),
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(left: _leadingPadding, right: 1000),
      controller: scrollController,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 2,
        mainAxisSpacing: 5,
      ),
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
      itemCount: 100,
      cacheExtent: double.maxFinite,
    );
  }
}
