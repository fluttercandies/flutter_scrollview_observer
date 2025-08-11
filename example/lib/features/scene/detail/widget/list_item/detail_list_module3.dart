/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/fluttercandies/flutter_scrollview_observer
 * @Date: 2025-08-02 21:32:21
 */

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scrollview_observer_example/features/scene/detail/header/detail_header.dart';
import 'package:scrollview_observer_example/features/scene/detail/logic/detail_logic.dart';
import 'package:scrollview_observer_example/features/scene/detail/state/detail_state.dart';
import 'package:scrollview_observer_example/features/scene/detail/widget/detail_list_item_wrapper.dart';

class DetailListModule3 extends StatefulWidget {
  const DetailListModule3({super.key});

  @override
  State<DetailListModule3> createState() => _DetailListModule3State();
}

class _DetailListModule3State extends State<DetailListModule3>
    with DetailLogicConsumerMixin<DetailListModule3> {
  DetailState get state => logic.state;

  List<IconData> icons = [
    Icons.flight,
    Icons.restaurant,
    Icons.shopping_bag,
    Icons.local_gas_station,
    Icons.movie,
    Icons.sports_soccer,
    Icons.music_note,
    Icons.fitness_center,
  ];

  List<String> titles = [
    'Flight',
    'Food',
    'Shopping',
    'Fuel',
    'Movie',
    'Sports',
    'Music',
    'Fitness',
  ];

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DetailLogic>(
      tag: logicTag,
      id: DetailUpdateType.module3,
      builder: (_) {
        if (!state.haveDataForModule3) return const SizedBox.shrink();

        Widget resultWidget = _buildGridView();
        resultWidget = DetailListItemWrapper(
          title: 'Module 3',
          child: resultWidget,
        );
        return resultWidget;
      },
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.8,
      ),
      itemCount: 8,
      itemBuilder: (context, index) {
        return _buildGridItem(index);
      },
    );
  }

  Widget _buildGridItem(int index) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildItemIcon(index),
        const SizedBox(height: 8),
        _buildItemTitle(index),
      ],
    );
  }

  Widget _buildItemTitle(int index) {
    return Text(
      titles[index],
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildItemIcon(int index) {
    Widget resultWidget = Icon(
      icons[index],
      color: Colors.blue.shade800,
      size: 30,
    );
    resultWidget = Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.blue.shade100,
        shape: BoxShape.circle,
      ),
      child: resultWidget,
    );
    return resultWidget;
  }
}
