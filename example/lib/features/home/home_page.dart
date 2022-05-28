import 'package:flutter/material.dart';
import 'package:scrollview_observer_example/features/listview/anchor_demo/anchor_page.dart';
import 'package:scrollview_observer_example/features/listview/listview_demo/listview_demo_page.dart';
import 'package:scrollview_observer_example/features/listview/sliver_list_demo/sliver_list_demo_page.dart';
import 'package:scrollview_observer_example/features/listview/video_auto_play_list/video_list_auto_play_page.dart';
import 'package:tuple/tuple.dart';

enum HomeListRowType {
  listView,
  sliverListView,
  videoAutoPlayList,
}

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
            title: Text(rowData.item2),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return rowData.item3;
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

  List<Tuple3<HomeListRowType, String, Widget>> _buildListViewRows(
    BuildContext context,
  ) {
    return [
      const Tuple3<HomeListRowType, String, Widget>(
        HomeListRowType.listView,
        "ListView",
        ListViewDemoPage(),
      ),
      const Tuple3<HomeListRowType, String, Widget>(
        HomeListRowType.sliverListView,
        "SliverListView",
        SliverListViewDemoPage(),
      ),
      const Tuple3<HomeListRowType, String, Widget>(
        HomeListRowType.videoAutoPlayList,
        "VideoList AutoPlay",
        VideoListAutoPlayPage(),
      ),
      const Tuple3<HomeListRowType, String, Widget>(
        HomeListRowType.videoAutoPlayList,
        "AnchorList",
        AnchorListPage(),
      ),
    ];
  }
}
