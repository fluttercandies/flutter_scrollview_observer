/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/fluttercandies/flutter_scrollview_observer
 * @Date: 2023-11-27 22:05:28
 */

import 'package:flutter/material.dart';
import 'package:scrollview_observer/scrollview_observer.dart';
import 'package:scrollview_observer_example/utils/snackbar.dart';

class NestedScrollViewDemoPage extends StatefulWidget {
  const NestedScrollViewDemoPage({Key? key}) : super(key: key);

  @override
  State<NestedScrollViewDemoPage> createState() =>
      _NestedScrollViewDemoPageState();
}

class _NestedScrollViewDemoPageState extends State<NestedScrollViewDemoPage> {
  BuildContext? _sliverHeaderListCtx;
  BuildContext? _sliverBodyListCtx;
  BuildContext? _sliverBodyGridCtx;

  GlobalKey nestedScrollViewKey = GlobalKey();
  GlobalKey appBarKey = GlobalKey();

  final nestedScrollUtil = NestedScrollUtil();

  int _hitIndexForListCtx = 0;
  List<int> _hitIndexesForGrid = [];

  ScrollController outerScrollController = ScrollController();

  ScrollController? bodyScrollController;

  late SliverObserverController observerController = SliverObserverController(
    controller: outerScrollController,
  );

  @override
  void dispose() {
    outerScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SliverViewObserver(
        controller: observerController,
        child: _buildNestedScrollView(),
        sliverContexts: () {
          return [
            if (_sliverHeaderListCtx != null) _sliverHeaderListCtx!,
            if (_sliverBodyListCtx != null) _sliverBodyListCtx!,
            if (_sliverBodyGridCtx != null) _sliverBodyGridCtx!,
          ];
        },
        customOverlap: (sliverContext) {
          return nestedScrollUtil.calcOverlap(
            nestedScrollViewKey: nestedScrollViewKey,
            sliverContext: sliverContext,
          );
        },
        onObserveAll: (result) {
          result.forEach((key, value) {
            if (key == _sliverHeaderListCtx) {
              debugPrint(
                  "SliverListHeaderCtx: ${value.displayingChildIndexList}");
            } else if (key == _sliverBodyListCtx) {
              final model = value as ListViewObserveModel;
              debugPrint("SliverListCtx: ${model.displayingChildIndexList}");
              if (_hitIndexForListCtx != model.firstChild?.index) {
                _hitIndexForListCtx = model.firstChild?.index ?? 0;
                setState(() {});
              }
            } else if (key == _sliverBodyGridCtx) {
              final model = value as GridViewObserveModel;
              debugPrint("SliverGridCtx: ${model.displayingChildIndexList}");
              final firstGroupChildIndexList =
                  model.firstGroupChildList.map((e) => e.index).toList();
              if (_hitIndexesForGrid != firstGroupChildIndexList) {
                _hitIndexesForGrid = firstGroupChildIndexList;
                setState(() {});
              }
            }
          });
        },
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            icon: const Icon(Icons.list_alt_rounded),
            onPressed: () {
              observerController.controller = outerScrollController;
              observerController.jumpTo(
                index: 1,
                sliverContext: _sliverHeaderListCtx,
                offset: calcPersistentHeaderExtent,
              );
              SnackBarUtil.showSnackBar(
                context: context,
                text: 'Header - SliverList - Jumping to item 1',
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.list_rounded),
            onPressed: () {
              observerController.controller = bodyScrollController;
              observerController.jumpTo(
                index: 5,
                sliverContext: _sliverBodyListCtx,
                offset: calcPersistentHeaderExtent,
              );
              SnackBarUtil.showSnackBar(
                context: context,
                text: 'Body - SliverList - Jumping to item 5',
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.grid_view),
            onPressed: () {
              observerController.controller = bodyScrollController;
              observerController.jumpTo(
                index: 5,
                sliverContext: _sliverBodyGridCtx,
                offset: calcPersistentHeaderExtent,
              );
              SnackBarUtil.showSnackBar(
                context: context,
                text: 'Body - SliverGrid - Jumping to item 5',
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.restore_outlined),
            onPressed: resetAllSliverObservationData,
          )
        ],
      ),
    );
  }

  Widget _buildNestedScrollView() {
    return NestedScrollView(
      key: nestedScrollViewKey,
      controller: outerScrollController,
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverAppBar(
            key: appBarKey,
            title: const Text("NestedScrollView"),
            pinned: true,
            forceElevated: innerBoxIsScrolled,
          ),
          SliverFixedExtentList(
            delegate: SliverChildBuilderDelegate(
              (ctx, index) {
                if (_sliverHeaderListCtx != ctx) {
                  _sliverHeaderListCtx = ctx;
                  nestedScrollUtil.headerSliverContexts.add(ctx);
                }
                return ListTile(
                  leading: Text("Item $index"),
                );
              },
              childCount: 5,
            ),
            itemExtent: 50,
          ),
        ];
      },
      body: Builder(builder: (context) {
        final innerScrollController = PrimaryScrollController.of(context);
        if (bodyScrollController != innerScrollController) {
          bodyScrollController = innerScrollController;
        }
        return CustomScrollView(
          slivers: [
            _buildSliverListView(),
            _buildSliverGridView(),
          ],
        );
      }),
    );
  }

  Widget _buildSliverListView() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (ctx, index) {
          if (_sliverBodyListCtx != ctx) {
            _sliverBodyListCtx = ctx;
            nestedScrollUtil.bodySliverContexts.add(ctx);
          }
          return Container(
            height: (index % 2 == 0) ? 80 : 50,
            color: _hitIndexForListCtx == index ? Colors.red : Colors.black12,
            child: Center(
              child: Text(
                "index -- $index",
                style: TextStyle(
                  color: _hitIndexForListCtx == index
                      ? Colors.white
                      : Colors.black,
                ),
              ),
            ),
          );
        },
        childCount: 30,
      ),
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
          if (_sliverBodyGridCtx != context) {
            _sliverBodyGridCtx = context;
            nestedScrollUtil.bodySliverContexts.add(context);
          }
          return Container(
            color: (_hitIndexesForGrid.contains(index))
                ? Colors.green
                : Colors.blue[100],
            child: Center(
              child: Text('index -- $index'),
            ),
          );
        },
        childCount: 150,
      ),
    );
  }

  double calcPersistentHeaderExtent(double offset) {
    return ObserverUtils.calcPersistentHeaderExtent(
      key: appBarKey,
      offset: offset,
    );
  }

  resetAllSliverObservationData() {
    nestedScrollUtil.reset();
    nestedScrollViewKey = GlobalKey();
    setState(() {});
    SnackBarUtil.showSnackBar(
      context: context,
      text: "Reset all sliver's observation data\n",
    );
  }
}
