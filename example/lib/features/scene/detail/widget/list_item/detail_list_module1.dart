/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/fluttercandies/flutter_scrollview_observer
 * @Date: 2025-08-02 21:32:17
 */

import 'package:flutter/material.dart';
import 'package:scrollview_observer_example/features/scene/detail/header/detail_header.dart';

class DetailListModule1 extends StatefulWidget {
  const DetailListModule1({super.key});

  @override
  State<DetailListModule1> createState() => _DetailListModule1State();
}

class _DetailListModule1State extends State<DetailListModule1>
    with DetailLogicConsumerMixin<DetailListModule1> {
  @override
  Widget build(BuildContext context) {
    Widget resultWidget = _buildPageView();
    return resultWidget;
  }

  Widget _buildPageView() {
    Widget resultWidget = PageView.builder(
      itemCount: 5,
      itemBuilder: (context, index) {
        return _buildPageItem(index);
      },
    );
    resultWidget = SizedBox(
      height: 200,
      child: resultWidget,
    );
    return resultWidget;
  }

  Widget _buildPageItem(int index) {
    Widget resultWidget = Stack(
      children: [
        _buildPageItemBody(index),
        Positioned(
          top: 16,
          right: 16,
          child: _buildPageItemIndex(index),
        ),
      ],
    );
    resultWidget = Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.purple.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: resultWidget,
    );
    return resultWidget;
  }

  Widget _buildPageItemBody(int index) {
    Widget resultWidget = Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Image Title ${index + 1}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                blurRadius: 4.0,
                color: Colors.black,
                offset: Offset(2.0, 2.0),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'This is a description for image ${index + 1}.',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            shadows: [
              Shadow(
                blurRadius: 4.0,
                color: Colors.black,
                offset: Offset(2.0, 2.0),
              ),
            ],
          ),
        ),
      ],
    );
    resultWidget = Padding(
      padding: const EdgeInsets.all(16),
      child: resultWidget,
    );
    return resultWidget;
  }

  Widget _buildPageItemIndex(int index) {
    Widget resultWidget = Text(
      '${index + 1}/5',
      style: const TextStyle(
        color: Colors.white,
        fontSize: 12,
      ),
    );
    resultWidget = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
      ),
      child: resultWidget,
    );
    return resultWidget;
  }
}
