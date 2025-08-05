/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/fluttercandies/flutter_scrollview_observer
 * @Date: 2025-08-02 21:32:08
 */

import 'package:flutter/material.dart';
import 'package:scrollview_observer_example/features/scene/detail/header/detail_header.dart';
import 'package:scrollview_observer_example/features/scene/detail/widget/detail_list_item_wrapper.dart';

class DetailListModule2 extends StatefulWidget {
  const DetailListModule2({super.key});

  @override
  State<DetailListModule2> createState() => _DetailListModule2State();
}

class _DetailListModule2State extends State<DetailListModule2>
    with DetailLogicConsumerMixin<DetailListModule2> {
  @override
  Widget build(BuildContext context) {
    Widget resultWidget = _buildListView();
    resultWidget = SizedBox(
      height: 300,
      child: resultWidget,
    );
    resultWidget = DetailListItemWrapper(
      title: 'Module 2',
      child: resultWidget,
    );
    return resultWidget;
  }

  Widget _buildListView() {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: 5,
      itemBuilder: (context, index) {
        return _buildItem(index);
      },
      separatorBuilder: (context, index) {
        return const SizedBox(width: 8);
      },
    );
  }

  Widget _buildItem(int index) {
    Widget resultWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            _buildItemCover(index),
            Positioned(
              top: 8,
              right: 8,
              child: _buildItemFavoriteIcon(),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildItemTitle(),
              const SizedBox(height: 8),
              _buildItemBrand(),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildItemPrice(),
                  _buildItemAddBtn(),
                ],
              ),
            ],
          ),
        ),
      ],
    );
    resultWidget = SizedBox(
      width: 200,
      child: resultWidget,
    );
    resultWidget = Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 2,
      child: resultWidget,
    );
    return resultWidget;
  }

  Widget _buildItemBrand() {
    return const Text(
      'NIKE',
      style: TextStyle(
        color: Colors.grey,
        fontSize: 12,
      ),
    );
  }

  Widget _buildItemTitle() {
    return const Text(
      'Air Force 1',
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    );
  }

  Widget _buildItemAddBtn() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.add,
        color: Colors.white,
        size: 24,
      ),
    );
  }

  Widget _buildItemPrice() {
    return const Text(
      '\$90.00',
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    );
  }

  Widget _buildItemFavoriteIcon() {
    Widget resultWidget = const Icon(
      Icons.favorite,
      color: Colors.red,
      size: 20,
    );
    resultWidget = Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      padding: const EdgeInsets.all(4.0),
      child: resultWidget,
    );
    return resultWidget;
  }

  Widget _buildItemCover(int index) {
    return Container(
      height: 150,
      alignment: Alignment.center,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(16.0),
        ),
      ),
    );
  }
}
