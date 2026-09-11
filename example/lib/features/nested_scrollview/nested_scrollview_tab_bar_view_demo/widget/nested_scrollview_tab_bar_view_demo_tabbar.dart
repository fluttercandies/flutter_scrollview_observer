/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/fluttercandies/flutter_scrollview_observer
 * @Date: 2026-02-24 21:28:34
 */

import 'package:material_ui/material_ui.dart';
import 'package:scrollview_observer_example/features/nested_scrollview/nested_scrollview_tab_bar_view_demo/header/nested_scrollview_tab_bar_view_demo_header.dart';
import 'package:scrollview_observer_example/features/nested_scrollview/nested_scrollview_tab_bar_view_demo/state/nested_scrollview_tab_bar_view_demo_state.dart';

class NestedScrollViewTabBarViewDemoTabBar extends StatefulWidget {
  const NestedScrollViewTabBarViewDemoTabBar({super.key});

  @override
  State<NestedScrollViewTabBarViewDemoTabBar> createState() =>
      _NestedScrollViewTabBarViewDemoTabBarState();
}

class _NestedScrollViewTabBarViewDemoTabBarState
    extends State<NestedScrollViewTabBarViewDemoTabBar>
    with
        NestedScrollviewTabBarViewDemoLogicConsumerMixin<
          NestedScrollViewTabBarViewDemoTabBar
        > {
  NestedScrollViewTabBarViewDemoState get state => logic.state;

  @override
  Widget build(BuildContext context) {
    Widget resultWidget = TabBar(
      controller: state.tabController,
      labelColor: Colors.blue,
      unselectedLabelColor: Colors.grey,
      indicatorSize: TabBarIndicatorSize.label,
      tabs: state.tabTypeList.map((e) => Tab(text: e.title)).toList(),
    );
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: resultWidget,
    );
  }
}
