/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/fluttercandies/flutter_scrollview_observer
 * @Date: 2026-02-24 22:25:39
 */

import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import 'package:scrollview_observer_example/features/nested_scrollview/nested_scrollview_tab_bar_view_demo/header/nested_scrollview_tab_bar_view_demo_header.dart';
import 'package:scrollview_observer_example/features/nested_scrollview/nested_scrollview_tab_bar_view_demo/logic/nested_scrollview_tab_bar_view_demo_logic.dart';
import 'package:scrollview_observer_example/features/nested_scrollview/nested_scrollview_tab_bar_view_demo/logic/nested_scrollview_tab_bar_view_demo_logic_observer.dart';
import 'package:scrollview_observer_example/features/nested_scrollview/nested_scrollview_tab_bar_view_demo/state/nested_scrollview_tab_bar_view_demo_state.dart';

class NestedScrollviewTabBarViewDemoTab1View extends StatefulWidget {
  const NestedScrollviewTabBarViewDemoTab1View({super.key});

  @override
  State<NestedScrollviewTabBarViewDemoTab1View> createState() =>
      _NestedScrollviewTabBarViewDemoTab1ViewState();
}

class _NestedScrollviewTabBarViewDemoTab1ViewState
    extends State<NestedScrollviewTabBarViewDemoTab1View>
    with
        NestedScrollviewTabBarViewDemoLogicConsumerMixin<
          NestedScrollviewTabBarViewDemoTab1View
        > {
  NestedScrollViewTabBarViewDemoState get state => logic.state;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NestedScrollViewTabBarViewDemoLogic>(
      tag: logicTag,
      id: NestedScrollviewTabBarViewDemoUpdateType.tab1View,
      builder: (_) {
        return _buildBody();
      },
    );
  }

  Widget _buildBody() {
    return CustomScrollView(
      key: const PageStorageKey("tab1"),
      slivers: [_buildSliverList()],
    );
  }

  Widget _buildSliverList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate((ctx, index) {
        logic.updateNestedScrollUtilBodySliverContextsIfNeed(
          oldCtx: state.sliverTab1ListCtx,
          newCtx: ctx,
          toRecordCtx: () {
            state.sliverTab1ListCtx = ctx;
          },
        );

        return ListTile(
          tileColor: state.hitIndexForTab1ListCtx == index ? Colors.red : null,
          title: Text("Tab 1 - List Item $index"),
        );
      }, childCount: 30),
    );
  }
}
