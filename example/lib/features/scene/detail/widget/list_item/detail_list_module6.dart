/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/fluttercandies/flutter_scrollview_observer
 * @Date: 2025-08-02 21:32:31
 */

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scrollview_observer_example/features/scene/detail/header/detail_header.dart';
import 'package:scrollview_observer_example/features/scene/detail/logic/detail_logic.dart';
import 'package:scrollview_observer_example/features/scene/detail/state/detail_state.dart';
import 'package:scrollview_observer_example/features/scene/detail/widget/detail_list_item_wrapper.dart';

class DetailListModule6 extends StatefulWidget {
  const DetailListModule6({super.key});

  @override
  State<DetailListModule6> createState() => _DetailListModule6State();
}

class _DetailListModule6State extends State<DetailListModule6>
    with DetailLogicConsumerMixin<DetailListModule6> {
  DetailState get state => logic.state;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DetailLogic>(
      tag: logicTag,
      id: DetailUpdateType.module6,
      builder: (_) {
        if (!state.haveDataForModule6) return const SizedBox.shrink();

        Widget resultWidget = _buildListView();
        resultWidget = DetailListItemWrapper(
          title: 'Module 6',
          child: resultWidget,
        );
        return resultWidget;
      },
    );
  }

  Widget _buildListView() {
    Widget resultWidget = ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: 5,
      itemBuilder: (context, index) {
        return _buildCardItem(index);
      },
    );
    resultWidget = SizedBox(
      height: 220,
      child: resultWidget,
    );
    return resultWidget;
  }

  Widget _buildCardItem(int index) {
    Widget resultWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCardItemImage(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCardItemTitle(index),
            const SizedBox(height: 4),
            _buildCardItemSubtitle(index),
          ],
        ),
      ],
    );
    resultWidget = SizedBox(
      width: 180,
      child: resultWidget,
    );
    resultWidget = Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: resultWidget,
    );
    resultWidget = Padding(
      padding: EdgeInsets.zero,
      child: resultWidget,
    );
    return resultWidget;
  }

  Widget _buildCardItemImage() {
    return Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade100,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(12),
        ),
      ),
    );
  }

  Widget _buildCardItemSubtitle(int index) {
    Widget resultWidget = Text(
      'Description for item ${index + 1}.',
      style: const TextStyle(
        color: Colors.grey,
        fontSize: 12,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
    resultWidget = Padding(
      padding: const EdgeInsets.all(8.0),
      child: resultWidget,
    );
    return resultWidget;
  }

  Widget _buildCardItemTitle(int index) {
    Widget resultWidget = Text(
      'Title ${index + 1}',
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
    resultWidget = Padding(
      padding: const EdgeInsets.all(8.0),
      child: resultWidget,
    );
    return resultWidget;
  }
}
