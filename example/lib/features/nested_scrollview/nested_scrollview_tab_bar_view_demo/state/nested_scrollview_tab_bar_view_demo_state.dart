/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/fluttercandies/flutter_scrollview_observer
 * @Date: 2026-02-23 22:19:39
 */

import 'package:material_ui/material_ui.dart';
import 'package:scrollview_observer/scrollview_observer.dart';
import 'package:scrollview_observer_example/features/nested_scrollview/nested_scrollview_tab_bar_view_demo/header/nested_scrollview_tab_bar_view_demo_header.dart';

class NestedScrollViewTabBarViewDemoState {
  BuildContext? rootContext;

  bool scrollToWithAnimation = false;

  GlobalKey nestedScrollViewKey = GlobalKey();

  GlobalKey appBarKey = GlobalKey();

  GlobalKey tabBarKey = GlobalKey();

  List<NestedScrollviewTabBarViewDemoTabType> tabTypeList = [
    NestedScrollviewTabBarViewDemoTabType.tab1,
    NestedScrollviewTabBarViewDemoTabType.tab2,
    NestedScrollviewTabBarViewDemoTabType.tab3,
  ];

  late TabController tabController;

  ScrollController outerScrollController = ScrollController();

  ScrollController? bodyScrollController;

  late SliverObserverController observerController = SliverObserverController(
    controller: outerScrollController,
  );

  late NestedScrollUtil nestedScrollUtil = NestedScrollUtil()
    ..outerScrollController = outerScrollController;

  BuildContext? headerSliverListCtx;
  int hitIndexForHeaderListCtx = 0;

  BuildContext? sliverTab1ListCtx;
  int hitIndexForTab1ListCtx = 0;

  BuildContext? tab2SliverGridCtx;
  List<int> hitIndexesForTab2Grid = [];

  BuildContext? tab3SliverListCtx;
  int hitIndexForTab3ListCtx = 0;

  BuildContext? tab3SliverGridCtx;
  List<int> hitIndexesForTab3Grid = [];
}
