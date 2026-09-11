/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/fluttercandies/flutter_scrollview_observer
 * @Date: 2026-02-23 22:19:39
 */

import 'package:material_ui/material_ui.dart';
import 'package:getx_helper/getx_helper.dart';
import 'package:scrollview_observer_example/features/nested_scrollview/nested_scrollview_tab_bar_view_demo/logic/nested_scrollview_tab_bar_view_demo_logic.dart';

typedef NestedScrollviewTabBarViewDemoLogicPutMixin<W extends StatefulWidget> =
    GetxLogicPutStateMixin<NestedScrollViewTabBarViewDemoLogic, W>;

typedef NestedScrollviewTabBarViewDemoLogicConsumerMixin<
  W extends StatefulWidget
> = GetxLogicConsumerStateMixin<NestedScrollViewTabBarViewDemoLogic, W>;

enum NestedScrollviewTabBarViewDemoUpdateType {
  scrollTypeSwitch,
  floatingActionButton,
  headerSliverList,
  tab1View,
  tab2View,
  tab3ViewSliverList,
  tab3ViewSliverGrid,
}

enum NestedScrollviewTabBarViewDemoTabType {
  tab1(title: "List"),
  tab2(title: "Grid"),
  tab3(title: "List+Grid");

  const NestedScrollviewTabBarViewDemoTabType({required this.title});

  final String title;
}

enum NestedScrollviewTabBarViewDemoFABClickType {
  headerSliverList,
  tab1SliverList,
  tab2SliverGrid,
  tab3SliverList,
  tab3SliverGrid,
}
