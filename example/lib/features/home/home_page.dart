/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/LinXunFeng/flutter_scrollview_observer
 * @Date: 2022-08-08 00:20:03
 */
import 'package:flutter/material.dart';
import 'package:scrollview_observer_example/features/custom_scrollview/custom_scrollview_demo/custom_scrollview_demo_page.dart';
import 'package:scrollview_observer_example/features/custom_scrollview/custom_scrollview_demo/multi_sliver_demo_page.dart';
import 'package:scrollview_observer_example/features/custom_scrollview/sliver_appbar_demo/sliver_appbar_demo_page.dart';
import 'package:scrollview_observer_example/features/gridview/gridview_ctx_demo/gridview_ctx_demo_page.dart';
import 'package:scrollview_observer_example/features/gridview/gridview_custom_demo/gridview_custom_demo_page.dart';
import 'package:scrollview_observer_example/features/gridview/gridview_demo/gridview_demo_page.dart';
import 'package:scrollview_observer_example/features/gridview/gridview_fixed_height_demo/gridview_fixed_height_demo_page.dart';
import 'package:scrollview_observer_example/features/gridview/horizontal_gridview_demo/horizontal_gridview_demo_page.dart';
import 'package:scrollview_observer_example/features/gridview/sliver_grid_demo/sliver_grid_demo_page.dart';
import 'package:scrollview_observer_example/features/listview/horizontal_listview_demo/horizontal_listview_page.dart';
import 'package:scrollview_observer_example/features/listview/infinite_listview_demo/infinite_listview_page.dart';
import 'package:scrollview_observer_example/features/listview/listview_ctx_demo/listview_ctx_demo_page.dart';
import 'package:scrollview_observer_example/features/listview/listview_custom_demo/listview_custom_demo_page.dart';
import 'package:scrollview_observer_example/features/listview/listview_demo/listview_demo_page.dart';
import 'package:scrollview_observer_example/features/listview/listview_dynamic_offset/listview_dynamic_offset_page.dart';
import 'package:scrollview_observer_example/features/listview/listview_fixed_height_demo/listview_fixed_height_demo_page.dart';
import 'package:scrollview_observer_example/features/listview/sliver_list_demo/sliver_list_demo_page.dart';
import 'package:scrollview_observer_example/features/nested_scrollview/nested_scrollview_demo/nested_scrollview_demo_page.dart';
import 'package:scrollview_observer_example/features/scene/anchor_demo/anchor_page.dart';
import 'package:scrollview_observer_example/features/scene/anchor_demo/anchor_waterfall_page.dart';
import 'package:scrollview_observer_example/features/scene/azlist_demo/azlist_page.dart';
import 'package:scrollview_observer_example/features/scene/chat_demo/page/chat_gpt_page.dart';
import 'package:scrollview_observer_example/features/scene/chat_demo/page/chat_page.dart';
import 'package:scrollview_observer_example/features/scene/image_tab_demo/image_tab_page.dart';
import 'package:scrollview_observer_example/features/scene/scrollview_form_demo/scrollview_form_demo_page.dart';
import 'package:scrollview_observer_example/features/scene/video_auto_play_list/video_list_auto_play_page.dart';
import 'package:scrollview_observer_example/features/scene/visibility_demo/page/visibility_listview_page.dart';
import 'package:scrollview_observer_example/features/scene/visibility_demo/page/visibility_scrollview_page.dart';
import 'package:scrollview_observer_example/features/scene/waterfall_flow_demo/waterfall_flow_page.dart';
import 'package:scrollview_observer_example/features/scene/waterfall_flow_fixed_height_demo/waterfall_flow_fixed_height_page.dart';
import 'package:tuple/tuple.dart';

typedef PageBuilder = Widget Function();

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var rowDataArr = _buildListViewRows(context);
    return Scaffold(
      appBar: AppBar(title: const Text("ScrollView Observer Example")),
      body: ListView.separated(
        itemCount: rowDataArr.length,
        itemBuilder: (context, index) {
          final rowData = rowDataArr[index];
          return ListTile(
            title: Text(rowData.item1),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return rowData.item2();
                  },
                ),
              );
            },
          );
        },
        separatorBuilder: (context, index) {
          return Container(color: Colors.grey, height: 0.5);
        },
      ),
    );
  }

  List<Tuple2<String, PageBuilder>> _buildListViewRows(
    BuildContext context,
  ) {
    return [
      Tuple2<String, PageBuilder>(
        "ListView",
        () {
          return const ListViewDemoPage();
        },
      ),
      Tuple2<String, PageBuilder>(
        "ListView - Context",
        () {
          return const ListViewCtxDemoPage();
        },
      ),
      Tuple2<String, PageBuilder>(
        "ListView - Fixed Height",
        () {
          return const ListViewFixedHeightDemoPage();
        },
      ),
      Tuple2<String, PageBuilder>(
        "ListView - Horizontal",
        () {
          return const HorizontalListViewPage();
        },
      ),
      Tuple2<String, PageBuilder>(
        "ListView - Dynamic Offset",
        () {
          return const ListViewDynamicOffsetPage();
        },
      ),
      Tuple2<String, PageBuilder>(
        "ListView - Custom",
        () {
          return const ListViewCustomDemoPage();
        },
      ),
      Tuple2<String, PageBuilder>(
        "ListView - Infinite",
        () {
          return const InfiniteListViewPage();
        },
      ),
      Tuple2<String, PageBuilder>(
        "SliverListView",
        () {
          return const SliverListViewDemoPage();
        },
      ),
      Tuple2<String, PageBuilder>(
        "GridView",
        () {
          return const GridViewDemoPage();
        },
      ),
      Tuple2<String, PageBuilder>(
        "GridView - Context",
        () {
          return const GridViewCtxDemoPage();
        },
      ),
      Tuple2<String, PageBuilder>(
        "GridView - Fixed Height",
        () {
          return const GridViewFixedHeightDemoPage();
        },
      ),
      Tuple2<String, PageBuilder>(
        "GridView - Horizontal",
        () {
          return const HorizontalGridViewDemoPage();
        },
      ),
      Tuple2<String, PageBuilder>(
        "GridView - Custom",
        () {
          return const GridViewCustomDemoPage();
        },
      ),
      Tuple2<String, PageBuilder>(
        "SliverGridView",
        () {
          return const SliverGridViewDemoPage();
        },
      ),
      Tuple2<String, PageBuilder>(
        "CustomScrollView",
        () {
          return const CustomScrollViewDemoPage();
        },
      ),
      Tuple2<String, PageBuilder>(
        "MultiSliver",
        () {
          return const MultiSliverDemoPage();
        },
      ),
      Tuple2<String, PageBuilder>(
        "SliverAppBar",
        () {
          return const SliverAppBarDemoPage();
        },
      ),
      Tuple2<String, PageBuilder>(
        "NestedScrollView",
        () {
          return const NestedScrollViewDemoPage();
        },
      ),
      Tuple2<String, PageBuilder>(
        "VideoList AutoPlay",
        () {
          return const VideoListAutoPlayPage();
        },
      ),
      Tuple2<String, PageBuilder>(
        "AnchorList",
        () {
          return const AnchorListPage();
        },
      ),
      Tuple2<String, PageBuilder>(
        "AnchorWaterfall",
        () {
          return const AnchorWaterfallPage();
        },
      ),
      Tuple2<String, PageBuilder>(
        "ImageTab",
        () {
          return const ImageTabPage();
        },
      ),
      Tuple2<String, PageBuilder>(
        "Chat",
        () {
          return const ChatPage();
        },
      ),
      Tuple2<String, PageBuilder>(
        "ChatGPT",
        () {
          return const ChatGPTPage();
        },
      ),
      Tuple2<String, PageBuilder>(
        "Waterfall Flow",
        () {
          return const WaterfallFlowPage();
        },
      ),
      Tuple2<String, PageBuilder>(
        "Waterfall Flow - Fixed Height",
        () {
          return const WaterfallFlowFixedHeightPage();
        },
      ),
      Tuple2<String, PageBuilder>(
        "ScrollView Form",
        () {
          return const ScrollViewFormDemoPage();
        },
      ),
      Tuple2<String, PageBuilder>(
        "Visibility ListView",
        () {
          return const VisibilityListViewPage();
        },
      ),
      Tuple2<String, PageBuilder>(
        "Visibility ScrollView",
        () {
          return const VisibilityScrollViewPage();
        },
      ),
      Tuple2<String, PageBuilder>(
        "AzList",
        () {
          return const AzListPage();
        },
      ),
    ];
  }
}
