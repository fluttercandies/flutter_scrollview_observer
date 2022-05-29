import 'package:flutter/material.dart';
import 'package:scrollview_observer_example/features/listview/anchor_demo/anchor_page.dart';
import 'package:scrollview_observer_example/features/listview/listview_demo/listview_demo_page.dart';
import 'package:scrollview_observer_example/features/listview/listview_dynamic_offset/listview_dynamic_offset_page.dart';
import 'package:scrollview_observer_example/features/listview/sliver_list_demo/sliver_list_demo_page.dart';
import 'package:scrollview_observer_example/features/listview/video_auto_play_list/video_list_auto_play_page.dart';
import 'package:tuple/tuple.dart';

typedef PageBuilder = Widget Function();

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var rowDataArr = _buildListViewRows(context);
    return Scaffold(
      appBar: AppBar(title: const Text("ListView Observer Example")),
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
        "ListView Dynamic Offset",
        () {
          return const ListViewDynamicOffsetPage();
        },
      ),
      Tuple2<String, PageBuilder>(
        "SliverListView",
        () {
          return const SliverListViewDemoPage();
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
    ];
  }
}
