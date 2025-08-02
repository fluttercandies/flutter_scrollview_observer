/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/fluttercandies/flutter_scrollview_observer
 * @Date: 2025-08-02 15:49:38
 */

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:scrollview_observer_example/common/route/route.dart';
import 'package:scrollview_observer_example/features/custom_scrollview/custom_scrollview_demo/custom_scrollview_center_demo_page.dart';
import 'package:scrollview_observer_example/features/custom_scrollview/custom_scrollview_demo/custom_scrollview_demo_page.dart';
import 'package:scrollview_observer_example/features/custom_scrollview/custom_scrollview_demo/multi_sliver_demo_page.dart';
import 'package:scrollview_observer_example/features/custom_scrollview/sliver_appbar_demo/sliver_appbar_demo_page.dart';
import 'package:scrollview_observer_example/features/gridview/gridview_ctx_demo/gridview_ctx_demo_page.dart';
import 'package:scrollview_observer_example/features/gridview/gridview_custom_demo/gridview_custom_demo_page.dart';
import 'package:scrollview_observer_example/features/gridview/gridview_demo/gridview_demo_page.dart';
import 'package:scrollview_observer_example/features/gridview/gridview_fixed_height_demo/gridview_fixed_height_demo_page.dart';
import 'package:scrollview_observer_example/features/gridview/horizontal_gridview_demo/horizontal_gridview_demo_page.dart';
import 'package:scrollview_observer_example/features/gridview/sliver_grid_demo/sliver_grid_demo_page.dart';
import 'package:scrollview_observer_example/features/home/home_page.dart';
import 'package:scrollview_observer_example/features/listview/horizontal_listview_demo/horizontal_listview_page.dart';
import 'package:scrollview_observer_example/features/listview/infinite_listview_demo/infinite_listview_page.dart';
import 'package:scrollview_observer_example/features/listview/listview_ctx_demo/listview_ctx_demo_page.dart';
import 'package:scrollview_observer_example/features/listview/listview_custom_demo/listview_custom_demo_page.dart';
import 'package:scrollview_observer_example/features/listview/listview_demo/listview_demo_page.dart';
import 'package:scrollview_observer_example/features/listview/listview_dynamic_offset/listview_dynamic_offset_page.dart';
import 'package:scrollview_observer_example/features/listview/listview_fixed_height_demo/listview_fixed_height_demo_page.dart';
import 'package:scrollview_observer_example/features/listview/sliver_list_demo/sliver_list_demo_page.dart';
import 'package:scrollview_observer_example/features/pageview/pageview_demo/pageview_demo_page.dart';
import 'package:scrollview_observer_example/features/pageview/pageview_demo/pageview_parallax_item_listener_page.dart';
import 'package:scrollview_observer_example/features/pageview/pageview_demo/pageview_parallax_page.dart';
import 'package:scrollview_observer_example/features/scene/anchor_demo/anchor_page.dart';
import 'package:scrollview_observer_example/features/scene/anchor_demo/anchor_waterfall_page.dart';
import 'package:scrollview_observer_example/features/scene/azlist_demo/azlist_page.dart';
import 'package:scrollview_observer_example/features/scene/chat_demo/page/chat_gpt_page.dart';
import 'package:scrollview_observer_example/features/scene/chat_demo/page/chat_page.dart';
import 'package:scrollview_observer_example/features/scene/expandable_carousel_slider_demo/expandable_carousel_slider_demo.dart';
import 'package:scrollview_observer_example/features/scene/image_tab_demo/image_tab_page.dart';
import 'package:scrollview_observer_example/features/scene/scrollview_form_demo/scrollview_form_demo_page.dart';
import 'package:scrollview_observer_example/features/scene/video_auto_play_list/video_list_auto_play_page.dart';
import 'package:scrollview_observer_example/features/scene/visibility_demo/page/visibility_listview_page.dart';
import 'package:scrollview_observer_example/features/scene/visibility_demo/page/visibility_scrollview_page.dart';
import 'package:scrollview_observer_example/features/scene/waterfall_flow_demo/waterfall_flow_page.dart';
import 'package:scrollview_observer_example/features/scene/waterfall_flow_fixed_height_demo/waterfall_flow_fixed_height_page.dart';

class MyPage {
  static const home = '/home';
  // ListView
  static const listView = '/list_view';
  static const listViewContext = '/list_view_context';
  static const listViewFixedHeight = '/list_view_fixed_height';
  static const listViewHorizontal = '/list_view_horizontal';
  static const listViewDynamicOffset = '/list_view_dynamic_offset';
  static const listViewCustom = '/list_view_custom';
  static const listViewInfinite = '/list_view_infinite';
  static const sliverListView = '/sliver_list_view';
  // GridView
  static const gridView = '/grid_view';
  static const gridViewContext = '/grid_view_context';
  static const gridViewFixedHeight = '/grid_view_fixed_height';
  static const gridViewHorizontal = '/grid_view_horizontal';
  static const gridViewCustom = '/grid_view_custom';
  static const sliverGridView = '/sliver_grid_view';
  // CustomScrollView
  static const customScrollView = '/custom_scroll_view';
  static const customScrollViewCenter = '/custom_scroll_view_center';
  static const multiSliver = '/multi_sliver';
  static const sliverAppBar = '/sliver_app_bar';
  // NestedScrollView
  static const nestedScrollView = '/nested_scroll_view';
  // PageView
  static const pageView = '/page_view';
  static const pageViewParallax = '/page_view_parallax';
  static const pageViewParallaxItemListener =
      '/page_view_parallax_item_listener';
  // Scene
  static const videoListAutoPlay = '/video_list_auto_play';
  static const anchorList = '/anchor_list';
  static const anchorWaterfall = '/anchor_waterfall';
  static const imageTab = '/image_tab';
  static const chat = '/chat';
  static const chatGPT = '/chat_gpt';
  static const waterfallFlow = '/waterfall_flow';
  static const waterfallFlowFixedHeight = '/waterfall_flow_fixed_height';
  static const scrollViewForm = '/scroll_view_form';
  static const visibilityListView = '/visibility_list_view';
  static const visibilityScrollView = '/visibility_scroll_view';
  static const azList = '/az_list';
  static const expandableCarouselSlider = '/expandable_carousel_slider';
}

class MyRoute {
  static final observer = RouteObserver<ModalRoute>();

  static final routerConfig = GoRouter(
    routes: routes,
    initialLocation: MyPage.home,
    observers: [
      observer,
    ],
    navigatorKey: NavigationService.navigatorKey,
    debugLogDiagnostics: !kReleaseMode,
  );

  static final List<RouteBase> routes = [
    GoRoute(
      path: MyPage.home,
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: MyPage.listView,
      builder: (context, state) => const ListViewDemoPage(),
    ),
    GoRoute(
      path: MyPage.listViewContext,
      builder: (context, state) => const ListViewCtxDemoPage(),
    ),
    GoRoute(
      path: MyPage.listViewFixedHeight,
      builder: (context, state) => const ListViewFixedHeightDemoPage(),
    ),
    GoRoute(
      path: MyPage.listViewHorizontal,
      builder: (context, state) => const HorizontalListViewPage(),
    ),
    GoRoute(
      path: MyPage.listViewDynamicOffset,
      builder: (context, state) => const ListViewDynamicOffsetPage(),
    ),
    GoRoute(
      path: MyPage.listViewCustom,
      builder: (context, state) => const ListViewCustomDemoPage(),
    ),
    GoRoute(
      path: MyPage.listViewInfinite,
      builder: (context, state) => const InfiniteListViewPage(),
    ),
    GoRoute(
      path: MyPage.sliverListView,
      builder: (context, state) => const SliverListViewDemoPage(),
    ),
    GoRoute(
      path: MyPage.gridView,
      builder: (context, state) => const GridViewDemoPage(),
    ),
    GoRoute(
      path: MyPage.gridViewContext,
      builder: (context, state) => const GridViewCtxDemoPage(),
    ),
    GoRoute(
      path: MyPage.gridViewFixedHeight,
      builder: (context, state) => const GridViewFixedHeightDemoPage(),
    ),
    GoRoute(
      path: MyPage.gridViewHorizontal,
      builder: (context, state) => const HorizontalGridViewDemoPage(),
    ),
    GoRoute(
      path: MyPage.gridViewCustom,
      builder: (context, state) => const GridViewCustomDemoPage(),
    ),
    GoRoute(
      path: MyPage.sliverGridView,
      builder: (context, state) => const SliverGridViewDemoPage(),
    ),
    GoRoute(
      path: MyPage.customScrollView,
      builder: (context, state) => const CustomScrollViewDemoPage(),
    ),
    GoRoute(
      path: MyPage.customScrollViewCenter,
      builder: (context, state) => const CustomScrollViewCenterDemoPage(),
    ),
    GoRoute(
      path: MyPage.multiSliver,
      builder: (context, state) => const MultiSliverDemoPage(),
    ),
    GoRoute(
      path: MyPage.sliverAppBar,
      builder: (context, state) => const SliverAppBarDemoPage(),
    ),
    GoRoute(
      path: MyPage.nestedScrollView,
      builder: (context, state) => const SliverAppBarDemoPage(),
    ),
    GoRoute(
      path: MyPage.pageView,
      builder: (context, state) => const PageViewDemoPage(),
    ),
    GoRoute(
      path: MyPage.pageViewParallax,
      builder: (context, state) => const PageViewParallaxPage(),
    ),
    GoRoute(
      path: MyPage.pageViewParallaxItemListener,
      builder: (context, state) => const PageViewParallaxItemListenerPage(),
    ),
    GoRoute(
      path: MyPage.videoListAutoPlay,
      builder: (context, state) => const VideoListAutoPlayPage(),
    ),
    GoRoute(
      path: MyPage.anchorList,
      builder: (context, state) => const AnchorListPage(),
    ),
    GoRoute(
      path: MyPage.anchorWaterfall,
      builder: (context, state) => const AnchorWaterfallPage(),
    ),
    GoRoute(
      path: MyPage.imageTab,
      builder: (context, state) => const ImageTabPage(),
    ),
    GoRoute(
      path: MyPage.chat,
      builder: (context, state) => const ChatPage(),
    ),
    GoRoute(
      path: MyPage.chatGPT,
      builder: (context, state) => const ChatGPTPage(),
    ),
    GoRoute(
      path: MyPage.waterfallFlow,
      builder: (context, state) => const WaterfallFlowPage(),
    ),
    GoRoute(
      path: MyPage.waterfallFlowFixedHeight,
      builder: (context, state) => const WaterfallFlowFixedHeightPage(),
    ),
    GoRoute(
      path: MyPage.scrollViewForm,
      builder: (context, state) => const ScrollViewFormDemoPage(),
    ),
    GoRoute(
      path: MyPage.visibilityListView,
      builder: (context, state) => const VisibilityListViewPage(),
    ),
    GoRoute(
      path: MyPage.visibilityScrollView,
      builder: (context, state) => const VisibilityScrollViewPage(),
    ),
    GoRoute(
      path: MyPage.azList,
      builder: (context, state) => const AzListPage(),
    ),
    GoRoute(
      path: MyPage.expandableCarouselSlider,
      builder: (context, state) => const ExpandableCarouselSliderDemo(),
    ),
  ];
}
