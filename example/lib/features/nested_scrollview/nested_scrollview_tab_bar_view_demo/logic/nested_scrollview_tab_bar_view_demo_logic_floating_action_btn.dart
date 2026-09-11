/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/fluttercandies/flutter_scrollview_observer
 * @Date: 2026-02-24 23:20:17
 */

import 'package:scrollview_observer/scrollview_observer.dart';
import 'package:scrollview_observer_example/features/nested_scrollview/nested_scrollview_tab_bar_view_demo/header/nested_scrollview_tab_bar_view_demo_header.dart';
import 'package:scrollview_observer_example/features/nested_scrollview/nested_scrollview_tab_bar_view_demo/logic/nested_scrollview_tab_bar_view_demo_logic.dart';
import 'package:scrollview_observer_example/features/nested_scrollview/nested_scrollview_tab_bar_view_demo/logic/nested_scrollview_tab_bar_view_demo_logic_observer.dart';
import 'package:scrollview_observer_example/utils/snackbar.dart';

extension NestedScrollViewTabBarViewDemoLogicForFAB
    on NestedScrollViewTabBarViewDemoLogic {
  void handleFABClick(NestedScrollviewTabBarViewDemoFABClickType type) {
    final context = state.rootContext;
    if (context == null) return;

    switch (type) {
      case NestedScrollviewTabBarViewDemoFABClickType.headerSliverList:
        scrollTo(
          position: NestedScrollUtilPosition.header,
          index: 1,
          sliverContext: state.headerSliverListCtx,
        );
        SnackBarUtil.showSnackBar(
          context: context,
          text: 'Header - SliverList - Scrolling to item 1',
        );
        break;
      case NestedScrollviewTabBarViewDemoFABClickType.tab1SliverList:
        scrollTo(
          position: NestedScrollUtilPosition.body,
          index: 1,
          sliverContext: state.sliverTab1ListCtx,
        );
        SnackBarUtil.showSnackBar(
          context: context,
          text: 'Body - Tab1 SliverList - Scrolling to item 1',
        );
        break;
      case NestedScrollviewTabBarViewDemoFABClickType.tab2SliverGrid:
        scrollTo(
          position: NestedScrollUtilPosition.body,
          index: 1,
          sliverContext: state.tab2SliverGridCtx,
        );
        SnackBarUtil.showSnackBar(
          context: context,
          text: 'Body - Tab2 SliverGrid - Scrolling to item 1',
        );
        break;
      case NestedScrollviewTabBarViewDemoFABClickType.tab3SliverList:
        scrollTo(
          position: NestedScrollUtilPosition.body,
          index: 1,
          sliverContext: state.tab3SliverListCtx,
        );
        SnackBarUtil.showSnackBar(
          context: context,
          text: 'Body - Tab3 SliverList - Scrolling to item 1',
        );

        break;
      case NestedScrollviewTabBarViewDemoFABClickType.tab3SliverGrid:
        scrollTo(
          position: NestedScrollUtilPosition.body,
          index: 1,
          sliverContext: state.tab3SliverGridCtx,
        );
        SnackBarUtil.showSnackBar(
          context: context,
          text: 'Body - Tab3 SliverGrid - Scrolling to item 1',
        );
        break;
    }
  }
}
