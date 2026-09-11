/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/fluttercandies/flutter_scrollview_observer
 * @Date: 2026-02-24 22:35:11
 */

import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import 'package:scrollview_observer_example/features/nested_scrollview/nested_scrollview_tab_bar_view_demo/header/nested_scrollview_tab_bar_view_demo_header.dart';
import 'package:scrollview_observer_example/features/nested_scrollview/nested_scrollview_tab_bar_view_demo/logic/nested_scrollview_tab_bar_view_demo_logic.dart';
import 'package:scrollview_observer_example/features/nested_scrollview/nested_scrollview_tab_bar_view_demo/logic/nested_scrollview_tab_bar_view_demo_logic_observer.dart';
import 'package:scrollview_observer_example/features/nested_scrollview/nested_scrollview_tab_bar_view_demo/state/nested_scrollview_tab_bar_view_demo_state.dart';

class NestedScrollviewTabBarViewDemoTab3View extends StatefulWidget {
  const NestedScrollviewTabBarViewDemoTab3View({super.key});

  @override
  State<NestedScrollviewTabBarViewDemoTab3View> createState() =>
      _NestedScrollviewTabBarViewDemoTab3ViewState();
}

class _NestedScrollviewTabBarViewDemoTab3ViewState
    extends State<NestedScrollviewTabBarViewDemoTab3View>
    with
        NestedScrollviewTabBarViewDemoLogicConsumerMixin<
          NestedScrollviewTabBarViewDemoTab3View
        > {
  NestedScrollViewTabBarViewDemoState get state => logic.state;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      key: const PageStorageKey("tab3"),
      slivers: [
        GetBuilder<NestedScrollViewTabBarViewDemoLogic>(
          tag: logicTag,
          id: NestedScrollviewTabBarViewDemoUpdateType.tab3ViewSliverList,
          builder: (_) => _buildSliverList(),
        ),
        GetBuilder<NestedScrollViewTabBarViewDemoLogic>(
          tag: logicTag,
          id: NestedScrollviewTabBarViewDemoUpdateType.tab3ViewSliverGrid,
          builder: (_) => _buildSliverGrid(),
        ),
      ],
    );
  }

  Widget _buildSliverList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate((ctx, index) {
        logic.updateNestedScrollUtilBodySliverContextsIfNeed(
          oldCtx: state.tab3SliverListCtx,
          newCtx: ctx,
          toRecordCtx: () {
            state.tab3SliverListCtx = ctx;
          },
        );

        return ListTile(
          tileColor: state.hitIndexForTab3ListCtx == index ? Colors.red : null,
          title: Text("Tab 3 - List Item $index"),
        );
      }, childCount: 10),
    );
  }

  Widget _buildSliverGrid() {
    Widget resultWidget = SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10.0,
        crossAxisSpacing: 10.0,
        childAspectRatio: 2.0,
      ),
      delegate: SliverChildBuilderDelegate((ctx, index) {
        logic.updateNestedScrollUtilBodySliverContextsIfNeed(
          oldCtx: state.tab3SliverGridCtx,
          newCtx: ctx,
          toRecordCtx: () {
            state.tab3SliverGridCtx = ctx;
          },
        );

        return Container(
          color: state.hitIndexesForTab3Grid.contains(index)
              ? Colors.green
              : Colors.green[100],
          alignment: Alignment.center,
          child: Text('Tab 3 - Grid Item $index'),
        );
      }, childCount: 20),
    );
    resultWidget = SliverPadding(
      padding: const EdgeInsets.all(8),
      sliver: resultWidget,
    );
    return resultWidget;
  }
}
