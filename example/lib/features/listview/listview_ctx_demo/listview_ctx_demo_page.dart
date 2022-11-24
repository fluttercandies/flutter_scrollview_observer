/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/LinXunFeng/flutter_scrollview_observer
 * @Date: 2022-08-08 00:20:03
 */
import 'package:flutter/material.dart';
import 'package:scrollview_observer/scrollview_observer.dart';
import 'package:scrollview_observer_example/typedefs.dart';

class ListViewCtxDemoPage extends StatefulWidget {
  const ListViewCtxDemoPage({Key? key}) : super(key: key);

  @override
  State<ListViewCtxDemoPage> createState() => _ListViewCtxDemoPageState();
}

class _ListViewCtxDemoPageState extends State<ListViewCtxDemoPage> {
  BuildContext? _sliverListViewContext;

  int _hitIndex = 0;

  @override
  void initState() {
    super.initState();

    // Trigger an observation manually
    ambiguate(WidgetsBinding.instance)?.addPostFrameCallback((timeStamp) {
      ListViewOnceObserveNotification().dispatch(_sliverListViewContext);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("ListView")),
      body: ListViewObserver(
        child: _buildListView(),
        sliverListContexts: () {
          return [if (_sliverListViewContext != null) _sliverListViewContext!];
        },
        onObserveAll: (resultMap) {
          final model = resultMap[_sliverListViewContext];
          if (model == null) return;

          debugPrint('visible -- ${model.visible}');
          debugPrint('firstChild.index -- ${model.firstChild?.index}');
          debugPrint('displaying -- ${model.displayingChildIndexList}');
          setState(() {
            _hitIndex = model.firstChild?.index ?? 0;
          });
        },
      ),
    );
  }

  ListView _buildListView() {
    // return ListView.builder(
    //   padding: EdgeInsets.zero,
    //   itemCount: 200,
    //   itemBuilder: (ctx, index) {
    //     if (_sliverListViewContext != ctx) {
    //       _sliverListViewContext = ctx;
    //     }
    //     return _buildListItemView(index);
    //   },
    // );

    return ListView.separated(
      padding: const EdgeInsets.only(top: 1000, bottom: 1000),
      controller: ScrollController(initialScrollOffset: 1000),
      itemBuilder: (ctx, index) {
        if (_sliverListViewContext != ctx) {
          _sliverListViewContext = ctx;
        }
        return _buildListItemView(index);
      },
      separatorBuilder: (ctx, index) {
        return _buildSeparatorView();
      },
      itemCount: 50,
    );
  }

  Widget _buildListItemView(int index) {
    return Container(
      height: (index % 2 == 0) ? 80 : 50,
      color: _hitIndex == index ? Colors.red : Colors.black12,
      child: Center(
        child: Text(
          "index -- $index",
          style: TextStyle(
            color: _hitIndex == index ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  Container _buildSeparatorView() {
    return Container(
      color: Colors.white,
      height: 5,
    );
  }
}
