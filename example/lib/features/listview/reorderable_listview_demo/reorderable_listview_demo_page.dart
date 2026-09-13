/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/fluttercandies/flutter_scrollview_observer
 * @Date: 2026-09-13 16:00:00
 */

import 'package:flutter/material.dart';
import 'package:scrollview_observer/scrollview_observer.dart';
import 'package:scrollview_observer_example/utils/snackbar.dart';

class ReorderableListViewDemoPage extends StatefulWidget {
  const ReorderableListViewDemoPage({Key? key}) : super(key: key);

  @override
  State<ReorderableListViewDemoPage> createState() =>
      _ReorderableListViewDemoPageState();
}

class _ReorderableListViewDemoPageState
    extends State<ReorderableListViewDemoPage> {
  final items = List.generate(100, (index) => index);

  int _hitIndex = 0;

  /// Whether to use the prototypeItem of [ReorderableListView].
  bool _usePrototypeItem = false;

  ScrollController scrollController = ScrollController();

  late ListObserverController observerController;

  @override
  void initState() {
    super.initState();

    observerController = ListObserverController(controller: scrollController);
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget resultWidget = _buildListView();
    resultWidget = ListViewObserver(
      child: resultWidget,
      controller: observerController,
      onObserve: (resultModel) {
        setState(() {
          _hitIndex = resultModel.firstChild?.index ?? 0;
        });
      },
    );
    resultWidget = Scaffold(
      appBar: _buildAppBar(),
      body: resultWidget,
      floatingActionButton: _buildJumpButton(),
    );
    return resultWidget;
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text("ReorderableListView"),
      actions: [
        _buildPrototypeItemSwitch(),
      ],
    );
  }

  Widget _buildPrototypeItemSwitch() {
    final prototypeItemSwitch = Switch(
      value: _usePrototypeItem,
      onChanged: (value) => _onPrototypeItemChanged(value: value),
    );
    Widget resultWidget = Row(
      children: [
        const Text('prototypeItem'),
        prototypeItemSwitch,
      ],
    );
    return resultWidget;
  }

  Widget _buildJumpButton() {
    Widget resultWidget = const Icon(Icons.airline_stops_outlined);
    resultWidget = FloatingActionButton(
      child: resultWidget,
      onPressed: () => _onJumpToItem(item: 50),
    );
    return resultWidget;
  }

  Widget _buildListView() {
    return ReorderableListView.builder(
      // It must be the same as the controller of ListObserverController.
      scrollController: scrollController,
      prototypeItem: _usePrototypeItem ? const SizedBox(height: 80) : null,
      itemBuilder: (ctx, index) {
        return _buildListItemView(index: index);
      },
      itemCount: items.length,
      onReorderItem: (oldIndex, newIndex) => _onReorderItem(
        oldIndex: oldIndex,
        newIndex: newIndex,
      ),
    );
  }

  Widget _buildListItemView({required int index}) {
    final item = items[index];
    final isHit = _hitIndex == index;
    Widget resultWidget = Text(
      "item -- $item, index -- $index",
      style: TextStyle(
        color: isHit ? Colors.white : Colors.black,
      ),
    );
    resultWidget = Center(child: resultWidget);
    resultWidget = Container(
      margin: const EdgeInsets.only(bottom: 5),
      color: isHit ? Colors.red : Colors.black12,
      child: resultWidget,
    );
    resultWidget = SizedBox(
      // The key is required by ReorderableListView.
      key: ValueKey(item),
      height: _usePrototypeItem || item.isEven ? 80 : 50,
      child: resultWidget,
    );
    return resultWidget;
  }

  void _onPrototypeItemChanged({required bool value}) {
    setState(() {
      _usePrototypeItem = value;
    });
    // The type of the sliver will be changed, so the sliver context needs to
    // be re-recorded.
    observerController.reattach();
  }

  void _onJumpToItem({required int item}) {
    // The index of the item would be changed after reordering.
    final index = items.indexOf(item);
    SnackBarUtil.showSnackBar(
      context: context,
      text: 'Jump to item $item, index $index',
    );
    observerController.jumpTo(
      index: index,
      isFixedHeight: _usePrototypeItem,
    );
  }

  void _onReorderItem({
    required int oldIndex,
    required int newIndex,
  }) {
    setState(() {
      items.insert(newIndex, items.removeAt(oldIndex));
    });
  }
}
