/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/fluttercandies/flutter_scrollview_observer
 * @Date: 2025-08-02 21:30:01
 */

import 'package:flutter/material.dart';
import 'package:scrollview_observer_example/features/scene/detail/header/detail_header.dart';
import 'package:scrollview_observer_example/features/scene/detail/widget/detail_list_item_wrapper.dart';

class DetailListModule4 extends StatefulWidget {
  const DetailListModule4({super.key});

  @override
  State<DetailListModule4> createState() => _DetailListModule4State();
}

class _DetailListModule4State extends State<DetailListModule4>
    with DetailLogicConsumerMixin<DetailListModule4> {
  @override
  Widget build(BuildContext context) {
    Widget resultWidget = _buildListView();
    resultWidget = DetailListItemWrapper(
      title: 'Module 4',
      child: resultWidget,
    );
    return resultWidget;
  }

  Widget _buildListView() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) {
        return _buildItem(index);
      },
      itemCount: 5,
    );
  }

  Widget _buildItem(int index) {
    Widget resultWidget = Row(
      children: [
        _buildItemAvatar(),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildItemTitle(index),
              const SizedBox(height: 4),
              _buildItemSubtitle(index),
            ],
          ),
        ),
        _buildItemArrow(),
      ],
    );
    resultWidget = Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 8,
      ),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.grey,
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: resultWidget,
    );
    return resultWidget;
  }

  Widget _buildItemSubtitle(int index) {
    return Text(
      'Software Engineer - Company ${index + 1}',
      style: const TextStyle(
        color: Colors.grey,
        fontSize: 14,
      ),
    );
  }

  Widget _buildItemTitle(int index) {
    return Text(
      'User Name ${index + 1}',
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    );
  }

  Widget _buildItemAvatar() {
    return CircleAvatar(
      radius: 30,
      backgroundColor: Colors.blue.shade100,
      child: Icon(
        Icons.person,
        size: 30,
        color: Colors.blue.shade800,
      ),
    );
  }

  Widget _buildItemArrow() {
    return Icon(
      Icons.arrow_forward_ios,
      color: Colors.grey.shade400,
    );
  }
}
