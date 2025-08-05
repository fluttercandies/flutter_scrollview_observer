/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/LinXunFeng/flutter_scrollview_observer
 * @Date: 2022-08-08 00:20:03
 */

import 'package:flutter/material.dart';
import 'package:scrollview_observer_example/common/route/route.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("ScrollView Observer Example")),
      body: _buildListView(),
    );
  }

  Widget _buildListView() {
    return ListView(
      children: [
        ListTile(
          title: const Text("ListView"),
          onTap: () {
            NavigationService.push(MyPage.listView);
          },
        ),
        ListTile(
          title: const Text("ListView - Context"),
          onTap: () {
            NavigationService.push(MyPage.listViewContext);
          },
        ),
        ListTile(
          title: const Text("ListView - Fixed Height"),
          onTap: () {
            NavigationService.push(MyPage.listViewFixedHeight);
          },
        ),
        ListTile(
          title: const Text("ListView - Horizontal"),
          onTap: () {
            NavigationService.push(MyPage.listViewHorizontal);
          },
        ),
        ListTile(
          title: const Text("ListView - Dynamic Offset"),
          onTap: () {
            NavigationService.push(MyPage.listViewDynamicOffset);
          },
        ),
        ListTile(
          title: const Text("ListView - Custom"),
          onTap: () {
            NavigationService.push(MyPage.listViewCustom);
          },
        ),
        ListTile(
          title: const Text("ListView - Infinite"),
          onTap: () {
            NavigationService.push(MyPage.listViewInfinite);
          },
        ),
        ListTile(
          title: const Text("SliverListView"),
          onTap: () {
            NavigationService.push(MyPage.sliverListView);
          },
        ),
        ListTile(
          title: const Text("GridView"),
          onTap: () {
            NavigationService.push(MyPage.gridView);
          },
        ),
        ListTile(
          title: const Text("GridView - Context"),
          onTap: () {
            NavigationService.push(MyPage.gridViewContext);
          },
        ),
        ListTile(
          title: const Text("GridView - Fixed Height"),
          onTap: () {
            NavigationService.push(MyPage.gridViewFixedHeight);
          },
        ),
        ListTile(
          title: const Text("GridView - Horizontal"),
          onTap: () {
            NavigationService.push(MyPage.gridViewHorizontal);
          },
        ),
        ListTile(
          title: const Text("GridView - Custom"),
          onTap: () {
            NavigationService.push(MyPage.gridViewCustom);
          },
        ),
        ListTile(
          title: const Text("SliverGridView"),
          onTap: () {
            NavigationService.push(MyPage.sliverGridView);
          },
        ),
        ListTile(
          title: const Text("CustomScrollView"),
          onTap: () {
            NavigationService.push(MyPage.customScrollView);
          },
        ),
        ListTile(
          title: const Text("CustomScrollView - Center"),
          onTap: () {
            NavigationService.push(MyPage.customScrollViewCenter);
          },
        ),
        ListTile(
          title: const Text("MultiSliver"),
          onTap: () {
            NavigationService.push(MyPage.multiSliver);
          },
        ),
        ListTile(
          title: const Text("SliverAppBar"),
          onTap: () {
            NavigationService.push(MyPage.sliverAppBar);
          },
        ),
        ListTile(
          title: const Text("NestedScrollView"),
          onTap: () {
            NavigationService.push(MyPage.nestedScrollView);
          },
        ),
        ListTile(
          title: const Text("PageView"),
          onTap: () {
            NavigationService.push(MyPage.pageView);
          },
        ),
        ListTile(
          title: const Text("PageView - Parallax"),
          onTap: () {
            NavigationService.push(MyPage.pageViewParallax);
          },
        ),
        ListTile(
          title: const Text("PageView - Parallax ItemListener"),
          onTap: () {
            NavigationService.push(MyPage.pageViewParallaxItemListener);
          },
        ),
        ListTile(
          title: const Text("VideoList AutoPlay"),
          onTap: () {
            NavigationService.push(MyPage.videoListAutoPlay);
          },
        ),
        ListTile(
          title: const Text("AnchorList"),
          onTap: () {
            NavigationService.push(MyPage.anchorList);
          },
        ),
        ListTile(
          title: const Text("AnchorWaterfall"),
          onTap: () {
            NavigationService.push(MyPage.anchorWaterfall);
          },
        ),
        ListTile(
          title: const Text("ImageTab"),
          onTap: () {
            NavigationService.push(MyPage.imageTab);
          },
        ),
        ListTile(
          title: const Text("Chat"),
          onTap: () {
            NavigationService.push(MyPage.chat);
          },
        ),
        ListTile(
          title: const Text("ChatGPT"),
          onTap: () {
            NavigationService.push(MyPage.chatGPT);
          },
        ),
        ListTile(
          title: const Text("Waterfall Flow"),
          onTap: () {
            NavigationService.push(MyPage.waterfallFlow);
          },
        ),
        ListTile(
          title: const Text("Waterfall Flow - Fixed Height"),
          onTap: () {
            NavigationService.push(MyPage.waterfallFlowFixedHeight);
          },
        ),
        ListTile(
          title: const Text("ScrollView Form"),
          onTap: () {
            NavigationService.push(MyPage.scrollViewForm);
          },
        ),
        ListTile(
          title: const Text("Visibility ListView"),
          onTap: () {
            NavigationService.push(MyPage.visibilityListView);
          },
        ),
        ListTile(
          title: const Text("Visibility ScrollView"),
          onTap: () {
            NavigationService.push(MyPage.visibilityScrollView);
          },
        ),
        ListTile(
          title: const Text("AzList"),
          onTap: () {
            NavigationService.push(MyPage.azList);
          },
        ),
        ListTile(
          title: const Text("Expandable Carousel Slider"),
          onTap: () {
            NavigationService.push(MyPage.expandableCarouselSlider);
          },
        ),
        ListTile(
          title: const Text("Detail Page"),
          onTap: () {
            NavigationService.push(MyPage.detail);
          },
        ),
      ],
    );
  }
}
