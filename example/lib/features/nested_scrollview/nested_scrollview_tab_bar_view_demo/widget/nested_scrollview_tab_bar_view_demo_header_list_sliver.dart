/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/fluttercandies/flutter_scrollview_observer
 * @Date: 2026-02-24 23:03:32
 */

import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import 'package:scrollview_observer_example/features/nested_scrollview/nested_scrollview_tab_bar_view_demo/header/nested_scrollview_tab_bar_view_demo_header.dart';
import 'package:scrollview_observer_example/features/nested_scrollview/nested_scrollview_tab_bar_view_demo/logic/nested_scrollview_tab_bar_view_demo_logic.dart';
import 'package:scrollview_observer_example/features/nested_scrollview/nested_scrollview_tab_bar_view_demo/logic/nested_scrollview_tab_bar_view_demo_logic_observer.dart';
import 'package:scrollview_observer_example/features/nested_scrollview/nested_scrollview_tab_bar_view_demo/state/nested_scrollview_tab_bar_view_demo_state.dart';

class NestedScrollviewTabBarViewDemoHeaderListSliver extends StatefulWidget {
  const NestedScrollviewTabBarViewDemoHeaderListSliver({super.key});

  @override
  State<NestedScrollviewTabBarViewDemoHeaderListSliver> createState() =>
      _NestedScrollviewTabBarViewDemoHeaderListSliverState();
}

class _NestedScrollviewTabBarViewDemoHeaderListSliverState
    extends State<NestedScrollviewTabBarViewDemoHeaderListSliver>
    with
        NestedScrollviewTabBarViewDemoLogicConsumerMixin<
          NestedScrollviewTabBarViewDemoHeaderListSliver
        > {
  NestedScrollViewTabBarViewDemoState get state => logic.state;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NestedScrollViewTabBarViewDemoLogic>(
      tag: logicTag,
      id: NestedScrollviewTabBarViewDemoUpdateType.headerSliverList,
      builder: (_) {
        return _buildSliverList();
      },
    );
  }

  Widget _buildSliverList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate((ctx, index) {
        logic.updateNestedScrollUtilHeaderSliverContextsIfNeed(
          oldCtx: state.headerSliverListCtx,
          newCtx: ctx,
          toRecordCtx: () {
            state.headerSliverListCtx = ctx;
          },
        );

        return ListTile(
          title: Text("Header Item $index"),
          tileColor: state.hitIndexForHeaderListCtx == index
              ? Colors.orange
              : index % 2 == 0
              ? Colors.grey[100]
              : Colors.white,
        );
      }, childCount: 5),
    );
  }
}
