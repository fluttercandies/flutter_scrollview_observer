/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/fluttercandies/flutter_scrollview_observer
 * @Date: 2026-02-24 23:12:26
 */

import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import 'package:scrollview_observer_example/features/nested_scrollview/nested_scrollview_tab_bar_view_demo/header/nested_scrollview_tab_bar_view_demo_header.dart';
import 'package:scrollview_observer_example/features/nested_scrollview/nested_scrollview_tab_bar_view_demo/logic/nested_scrollview_tab_bar_view_demo_logic.dart';
import 'package:scrollview_observer_example/features/nested_scrollview/nested_scrollview_tab_bar_view_demo/logic/nested_scrollview_tab_bar_view_demo_logic_floating_action_btn.dart';
import 'package:scrollview_observer_example/features/nested_scrollview/nested_scrollview_tab_bar_view_demo/state/nested_scrollview_tab_bar_view_demo_state.dart';

class NestedScrollviewTabBarViewDemoFloatingActionBtn extends StatefulWidget {
  const NestedScrollviewTabBarViewDemoFloatingActionBtn({super.key});

  @override
  State<NestedScrollviewTabBarViewDemoFloatingActionBtn> createState() =>
      _NestedScrollviewTabBarViewDemoFloatingActionBtnState();
}

class _NestedScrollviewTabBarViewDemoFloatingActionBtnState
    extends State<NestedScrollviewTabBarViewDemoFloatingActionBtn>
    with
        NestedScrollviewTabBarViewDemoLogicConsumerMixin<
          NestedScrollviewTabBarViewDemoFloatingActionBtn
        > {
  NestedScrollViewTabBarViewDemoState get state => logic.state;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NestedScrollViewTabBarViewDemoLogic>(
      tag: logicTag,
      id: NestedScrollviewTabBarViewDemoUpdateType.floatingActionButton,
      builder: (_) {
        return _buildBody();
      },
    );
  }

  Widget _buildBody() {
    final index = state.tabController.index;
    final tabType = state.tabTypeList[index];
    switch (tabType) {
      case NestedScrollviewTabBarViewDemoTabType.tab1:
        return Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 10,
          children: [
            FloatingActionButton(
              heroTag: 'header_list',
              onPressed: () {
                logic.handleFABClick(
                  NestedScrollviewTabBarViewDemoFABClickType.headerSliverList,
                );
              },
              child: const Icon(Icons.list_alt_rounded),
            ),
            FloatingActionButton(
              heroTag: 'tab1_list',
              onPressed: () {
                logic.handleFABClick(
                  NestedScrollviewTabBarViewDemoFABClickType.tab1SliverList,
                );
              },
              child: const Icon(Icons.list),
            ),
          ],
        );
      case NestedScrollviewTabBarViewDemoTabType.tab2:
        return FloatingActionButton(
          heroTag: 'tab2_grid',
          onPressed: () {
            logic.handleFABClick(
              NestedScrollviewTabBarViewDemoFABClickType.tab2SliverGrid,
            );
          },
          child: const Icon(Icons.grid_view),
        );
      case NestedScrollviewTabBarViewDemoTabType.tab3:
        return Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 10,
          children: [
            FloatingActionButton(
              heroTag: 'tab3_list',
              onPressed: () {
                logic.handleFABClick(
                  NestedScrollviewTabBarViewDemoFABClickType.tab3SliverList,
                );
              },
              child: const Icon(Icons.list),
            ),
            FloatingActionButton(
              heroTag: 'tab3_grid',
              onPressed: () {
                logic.handleFABClick(
                  NestedScrollviewTabBarViewDemoFABClickType.tab3SliverGrid,
                );
              },
              child: const Icon(Icons.grid_view),
            ),
          ],
        );
    }
  }
}
