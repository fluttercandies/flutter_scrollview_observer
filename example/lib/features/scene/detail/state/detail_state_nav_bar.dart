/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/fluttercandies/flutter_scrollview_observer
 * @Date: 2025-08-03 21:08:34
 */

import 'package:flutter/material.dart';
import 'package:scrollview_observer_example/features/scene/detail/model/detail_nav_bar_tab_model.dart';

mixin DetailStateForNavBar {
  final double navBarHeight = kToolbarHeight;
  
  double navBarAlpha = 0;

  TabController? navBarTabController;

  List<DetailNavBarTabModel> navBarTabs = [];
}
