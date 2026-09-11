/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/fluttercandies/flutter_scrollview_observer
 * @Date: 2026-02-23 22:19:39
 */

import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import 'package:scrollview_observer/scrollview_observer.dart';
import 'package:scrollview_observer_example/features/nested_scrollview/nested_scrollview_tab_bar_view_demo/header/nested_scrollview_tab_bar_view_demo_header.dart';
import 'package:scrollview_observer_example/features/nested_scrollview/nested_scrollview_tab_bar_view_demo/logic/nested_scrollview_tab_bar_view_demo_logic.dart';
import 'package:scrollview_observer_example/features/nested_scrollview/nested_scrollview_tab_bar_view_demo/logic/nested_scrollview_tab_bar_view_demo_logic_observer.dart';
import 'package:scrollview_observer_example/features/nested_scrollview/nested_scrollview_tab_bar_view_demo/state/nested_scrollview_tab_bar_view_demo_state.dart';
import 'package:scrollview_observer_example/features/nested_scrollview/nested_scrollview_tab_bar_view_demo/widget/nested_scrollview_tab_bar_view_demo_floating_action_btn.dart';
import 'package:scrollview_observer_example/features/nested_scrollview/nested_scrollview_tab_bar_view_demo/widget/nested_scrollview_tab_bar_view_demo_header_list_sliver.dart';
import 'package:scrollview_observer_example/features/nested_scrollview/nested_scrollview_tab_bar_view_demo/widget/nested_scrollview_tab_bar_view_demo_scroll_type_switch.dart';
import 'package:scrollview_observer_example/features/nested_scrollview/nested_scrollview_tab_bar_view_demo/widget/nested_scrollview_tab_bar_view_demo_tab1_view.dart';
import 'package:scrollview_observer_example/features/nested_scrollview/nested_scrollview_tab_bar_view_demo/widget/nested_scrollview_tab_bar_view_demo_tab2_view.dart';
import 'package:scrollview_observer_example/features/nested_scrollview/nested_scrollview_tab_bar_view_demo/widget/nested_scrollview_tab_bar_view_demo_tab3_view.dart';
import 'package:scrollview_observer_example/features/nested_scrollview/nested_scrollview_tab_bar_view_demo/widget/nested_scrollview_tab_bar_view_demo_tabbar.dart';
import 'package:scrollview_observer_example/widgets/sliver.dart';

class NestedScrollViewTabBarViewDemoPage extends StatefulWidget {
  const NestedScrollViewTabBarViewDemoPage({super.key});

  @override
  State<NestedScrollViewTabBarViewDemoPage> createState() =>
      NestedScrollViewTabBarViewDemoPageState();
}

class NestedScrollViewTabBarViewDemoPageState
    extends State<NestedScrollViewTabBarViewDemoPage>
    with
        NestedScrollviewTabBarViewDemoLogicPutMixin<
          NestedScrollViewTabBarViewDemoPage
        >,
        TickerProviderStateMixin {
  NestedScrollViewTabBarViewDemoState get state => logic.state;

  NestedScrollUtil get nestedScrollUtil => state.nestedScrollUtil;

  @override
  void dispose() {
    logic.onDispose();
    super.dispose();
  }

  @override
  NestedScrollViewTabBarViewDemoLogic initLogic() =>
      NestedScrollViewTabBarViewDemoLogic();

  @override
  Widget buildBody(BuildContext context) {
    state.rootContext = context;

    Widget resultWidget = GetBuilder<NestedScrollViewTabBarViewDemoLogic>(
      tag: logicTag,
      assignId: true,
      builder: (_) {
        return _buildContent();
      },
    );
    resultWidget = Scaffold(
      body: resultWidget,
      floatingActionButton:
          const NestedScrollviewTabBarViewDemoFloatingActionBtn(),
    );
    return resultWidget;
  }

  Widget _buildContent() {
    Widget resultWidget = NestedScrollView(
      key: state.nestedScrollViewKey,
      controller: state.outerScrollController,
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          _buildSliverAppBar(innerBoxIsScrolled),
          const NestedScrollviewTabBarViewDemoHeaderListSliver(),
          SliverPersistentHeader(
            key: state.tabBarKey,
            pinned: true,
            delegate: SliverHeaderDelegate.fixedHeight(
              height: 50,
              child: const NestedScrollViewTabBarViewDemoTabBar(),
            ),
          ),
        ];
      },
      body: Builder(
        builder: (context) {
          final innerScrollController = PrimaryScrollController.of(context);
          if (nestedScrollUtil.bodyScrollController != innerScrollController) {
            nestedScrollUtil.bodyScrollController = innerScrollController;
          }
          return _buildTabBarView();
        },
      ),
    );

    resultWidget = SliverViewObserver(
      sliverContexts: () {
        final sliverHeaderListCtx = state.headerSliverListCtx;
        final sliverTab1ListCtx = state.sliverTab1ListCtx;
        final sliverTab2GridCtx = state.tab2SliverGridCtx;
        final sliverTab3ListCtx = state.tab3SliverListCtx;
        final sliverTab3GridCtx = state.tab3SliverGridCtx;

        return [
          ?sliverHeaderListCtx,
          ?sliverTab1ListCtx,
          ?sliverTab2GridCtx,
          ?sliverTab3ListCtx,
          ?sliverTab3GridCtx,
        ];
      },
      customOverlap: (sliverContext) {
        return nestedScrollUtil.calcOverlap(
          nestedScrollViewKey: state.nestedScrollViewKey,
          sliverContext: sliverContext,
        );
      },
      onObserveAll: logic.handleOnObserveAll,
      child: resultWidget,
    );

    return resultWidget;
  }

  Widget _buildTabBarView() {
    return TabBarView(
      controller: state.tabController,
      children: const [
        NestedScrollviewTabBarViewDemoTab1View(),
        NestedScrollviewTabBarViewDemoTab2View(),
        NestedScrollviewTabBarViewDemoTab3View(),
      ],
    );
  }

  Widget _buildSliverAppBar(bool innerBoxIsScrolled) {
    return SliverAppBar(
      key: state.appBarKey,
      title: const Text("Nested & TabBarView"),
      pinned: true,
      forceElevated: innerBoxIsScrolled,
      actions: const [NestedScrollviewTabBarViewDemoScrollTypeSwitch()],
    );
  }
}
