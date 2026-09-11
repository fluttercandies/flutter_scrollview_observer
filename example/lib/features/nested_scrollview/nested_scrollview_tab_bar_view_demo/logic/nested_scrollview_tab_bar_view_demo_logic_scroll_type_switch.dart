/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/fluttercandies/flutter_scrollview_observer
 * @Date: 2026-02-24 23:20:17
 */

import 'package:scrollview_observer_example/features/nested_scrollview/nested_scrollview_tab_bar_view_demo/header/nested_scrollview_tab_bar_view_demo_header.dart';
import 'package:scrollview_observer_example/features/nested_scrollview/nested_scrollview_tab_bar_view_demo/logic/nested_scrollview_tab_bar_view_demo_logic.dart';
import 'package:scrollview_observer_example/utils/snackbar.dart';

extension NestedScrollViewTabBarViewDemoLogicForScrollTypeSwitch
    on NestedScrollViewTabBarViewDemoLogic {
  void handleScrollTypeSwitchOnChanged(bool value) async {
    final context = state.rootContext;
    if (context == null) return;

    state.scrollToWithAnimation = value;
    update([NestedScrollviewTabBarViewDemoUpdateType.scrollTypeSwitch]);
    SnackBarUtil.showSnackBar(
      context: context,
      text:
          "Animated scrolling ${state.scrollToWithAnimation ? 'Enabled' : 'Disabled'}",
    );
  }
}
