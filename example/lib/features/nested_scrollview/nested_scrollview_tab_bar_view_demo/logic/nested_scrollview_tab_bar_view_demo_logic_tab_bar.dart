/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/fluttercandies/flutter_scrollview_observer
 * @Date: 2026-02-24 23:14:47
 */

import 'package:material_ui/material_ui.dart';
import 'package:scrollview_observer_example/features/nested_scrollview/nested_scrollview_tab_bar_view_demo/header/nested_scrollview_tab_bar_view_demo_header.dart';
import 'package:scrollview_observer_example/features/nested_scrollview/nested_scrollview_tab_bar_view_demo/logic/nested_scrollview_tab_bar_view_demo_logic.dart';

extension NestedScrollViewTabBarViewDemoLogicForTabBar
    on NestedScrollViewTabBarViewDemoLogic {
  void onInitForTabBar() async {
    state.tabController = TabController(
      length: state.tabTypeList.length,
      vsync: this,
    );
    state.tabController.addListener(() {
      if (state.tabController.indexIsChanging) return;
      update([NestedScrollviewTabBarViewDemoUpdateType.floatingActionButton]);
    });
  }

  void onDisposeForTabBar() {
    state.tabController.dispose();
  }
}
