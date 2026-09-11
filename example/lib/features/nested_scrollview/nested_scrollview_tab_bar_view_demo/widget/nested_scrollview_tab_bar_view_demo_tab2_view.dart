/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/fluttercandies/flutter_scrollview_observer
 * @Date: 2026-02-24 22:33:19
 */

import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import 'package:scrollview_observer_example/features/nested_scrollview/nested_scrollview_tab_bar_view_demo/header/nested_scrollview_tab_bar_view_demo_header.dart';
import 'package:scrollview_observer_example/features/nested_scrollview/nested_scrollview_tab_bar_view_demo/logic/nested_scrollview_tab_bar_view_demo_logic.dart';
import 'package:scrollview_observer_example/features/nested_scrollview/nested_scrollview_tab_bar_view_demo/logic/nested_scrollview_tab_bar_view_demo_logic_observer.dart';
import 'package:scrollview_observer_example/features/nested_scrollview/nested_scrollview_tab_bar_view_demo/state/nested_scrollview_tab_bar_view_demo_state.dart';

class NestedScrollviewTabBarViewDemoTab2View extends StatefulWidget {
  const NestedScrollviewTabBarViewDemoTab2View({super.key});

  @override
  State<NestedScrollviewTabBarViewDemoTab2View> createState() =>
      _NestedScrollviewTabBarViewDemoTab2ViewState();
}

class _NestedScrollviewTabBarViewDemoTab2ViewState
    extends State<NestedScrollviewTabBarViewDemoTab2View>
    with
        NestedScrollviewTabBarViewDemoLogicConsumerMixin<
          NestedScrollviewTabBarViewDemoTab2View
        > {
  NestedScrollViewTabBarViewDemoState get state => logic.state;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NestedScrollViewTabBarViewDemoLogic>(
      tag: logicTag,
      id: NestedScrollviewTabBarViewDemoUpdateType.tab2View,
      builder: (_) {
        return _buildBody();
      },
    );
  }

  Widget _buildBody() {
    return CustomScrollView(
      key: const PageStorageKey("tab2"),
      slivers: [_buildSliverGrid()],
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
          oldCtx: state.tab2SliverGridCtx,
          newCtx: ctx,
          toRecordCtx: () {
            state.tab2SliverGridCtx = ctx;
          },
        );

        return Container(
          color: state.hitIndexesForTab2Grid.contains(index)
              ? Colors.green
              : Colors.blue[100],
          alignment: Alignment.center,
          child: Text('Tab 2 - Grid Item $index'),
        );
      }, childCount: 30),
    );
    resultWidget = SliverPadding(
      padding: const EdgeInsets.all(8),
      sliver: resultWidget,
    );
    return resultWidget;
  }
}
