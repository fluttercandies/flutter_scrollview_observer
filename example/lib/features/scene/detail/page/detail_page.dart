/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/fluttercandies/flutter_scrollview_observer
 * @Date: 2025-08-02 19:57:05
 */

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scrollview_observer_example/features/scene/detail/header/detail_header.dart';
import 'package:scrollview_observer_example/features/scene/detail/logic/detail_logic.dart';
import 'package:scrollview_observer_example/features/scene/detail/state/detail_state.dart';
import 'package:scrollview_observer_example/features/scene/detail/widget/detail_list_view.dart';
import 'package:scrollview_observer_example/features/scene/detail/widget/detail_nav_bar.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({super.key});

  @override
  State<DetailPage> createState() => DetailPageState();
}

class DetailPageState extends State<DetailPage>
    with DetailLogicPutMixin<DetailPage> {
  DetailState get state => logic.state;

  @override
  void dispose() {
    logic.onDispose();
    super.dispose();
  }

  @override
  DetailLogic initLogic() => DetailLogic();

  @override
  Widget buildBody(BuildContext context) {
    return GetBuilder<DetailLogic>(
      tag: logicTag,
      assignId: true,
      builder: (_) {
        return Scaffold(
          appBar: _buildAppBar(),
          body: _buildBody(),
        );
      },
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('Detail Page'),
    );
  }

  Widget _buildBody() {
    return const Stack(
      children: [
        DetailListView(),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: DetailNavBar(),
        ),
      ],
    );
  }
}
