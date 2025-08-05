/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/fluttercandies/flutter_scrollview_observer
 * @Date: 2025-08-02 21:32:45
 */

import 'package:flutter/material.dart';
import 'package:scrollview_observer_example/features/scene/detail/header/detail_header.dart';
import 'package:scrollview_observer_example/features/scene/detail/widget/detail_list_item_wrapper.dart';

class DetailListModule8 extends StatefulWidget {
  const DetailListModule8({super.key});

  @override
  State<DetailListModule8> createState() => _DetailListModule8State();
}

class _DetailListModule8State extends State<DetailListModule8>
    with DetailLogicConsumerMixin<DetailListModule8> {
  @override
  Widget build(BuildContext context) {
    Widget resultWidget = _buildListView();
    resultWidget = DetailListItemWrapper(
      title: 'Module 8',
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
        _buildItemImage(),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildItemDetails(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
    resultWidget = Padding(
      padding: const EdgeInsets.all(8.0),
      child: resultWidget,
    );
    resultWidget = Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 8,
      ),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: resultWidget,
    );
    return resultWidget;
  }

  Widget _buildItemImage() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.blueGrey,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _buildItemDetails() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Air Jordan 1 Low SE',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'NIKE',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
        SizedBox(height: 4),
        Text(
          '\$120.00',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
