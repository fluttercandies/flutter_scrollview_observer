/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/fluttercandies/flutter_scrollview_observer
 * @Date: 2026-02-24 23:54:30
 */

import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import 'package:scrollview_observer_example/features/nested_scrollview/nested_scrollview_tab_bar_view_demo/header/nested_scrollview_tab_bar_view_demo_header.dart';
import 'package:scrollview_observer_example/features/nested_scrollview/nested_scrollview_tab_bar_view_demo/logic/nested_scrollview_tab_bar_view_demo_logic.dart';
import 'package:scrollview_observer_example/features/nested_scrollview/nested_scrollview_tab_bar_view_demo/logic/nested_scrollview_tab_bar_view_demo_logic_scroll_type_switch.dart';
import 'package:scrollview_observer_example/features/nested_scrollview/nested_scrollview_tab_bar_view_demo/state/nested_scrollview_tab_bar_view_demo_state.dart';

class NestedScrollviewTabBarViewDemoScrollTypeSwitch extends StatefulWidget {
  const NestedScrollviewTabBarViewDemoScrollTypeSwitch({super.key});

  @override
  State<NestedScrollviewTabBarViewDemoScrollTypeSwitch> createState() =>
      _NestedScrollviewTabBarViewDemoScrollTypeSwitchState();
}

class _NestedScrollviewTabBarViewDemoScrollTypeSwitchState
    extends State<NestedScrollviewTabBarViewDemoScrollTypeSwitch>
    with
        NestedScrollviewTabBarViewDemoLogicConsumerMixin<
          NestedScrollviewTabBarViewDemoScrollTypeSwitch
        > {
  NestedScrollViewTabBarViewDemoState get state => logic.state;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NestedScrollViewTabBarViewDemoLogic>(
      tag: logicTag,
      id: NestedScrollviewTabBarViewDemoUpdateType.scrollTypeSwitch,
      builder: (_) {
        return _buildBody();
      },
    );
  }

  Widget _buildBody() {
    return Switch(
      value: state.scrollToWithAnimation,
      onChanged: logic.handleScrollTypeSwitchOnChanged,
    );
  }
}
