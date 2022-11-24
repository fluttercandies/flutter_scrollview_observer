/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/LinXunFeng/flutter_scrollview_observer
 * @Date: 2022-08-08 00:20:03
 */
import 'package:flutter/material.dart';
import 'package:scrollview_observer/scrollview_observer.dart';
import 'package:scrollview_observer_example/typedefs.dart';

class GridViewDemoPage extends StatefulWidget {
  const GridViewDemoPage({Key? key}) : super(key: key);

  @override
  State<GridViewDemoPage> createState() => _GridViewDemoPageState();
}

class _GridViewDemoPageState extends State<GridViewDemoPage> {
  static const double _leadingPadding = 1000;

  List<int> _hitIndexs = [0, 1];

  ScrollController scrollController =
      ScrollController(initialScrollOffset: _leadingPadding);

  late GridObserverController observerController;

  @override
  void initState() {
    super.initState();

    observerController = GridObserverController(controller: scrollController);

    // Trigger an observation manually
    ambiguate(WidgetsBinding.instance)?.endOfFrame.then(
      (_) {
        if (mounted) {
          // After layout
          observerController.dispatchOnceObserve();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("GridView")),
      body: GridViewObserver(
        controller: observerController,
        onObserve: (result) {
          final model = result;
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
          observerController.jumpTo(
            index: 49,
          );
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
      padding: const EdgeInsets.only(top: _leadingPadding, bottom: 0),
      controller: scrollController,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 2,
        mainAxisSpacing: 5,
      ),
      itemBuilder: (context, index) {
        return Container(
          color: (_hitIndexs.contains(index)) ? Colors.red : Colors.blue[100],
          child: Center(
            child: Text('index -- $index'),
          ),
        );
      },
      itemCount: 50,
    );
  }
}
