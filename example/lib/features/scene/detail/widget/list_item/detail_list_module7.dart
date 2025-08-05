/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/fluttercandies/flutter_scrollview_observer
 * @Date: 2025-08-02 21:32:39
 */

import 'package:flutter/material.dart';
import 'package:scrollview_observer_example/features/scene/detail/header/detail_header.dart';
import 'package:scrollview_observer_example/features/scene/detail/widget/detail_list_item_wrapper.dart';

class DetailListModule7 extends StatefulWidget {
  const DetailListModule7({super.key});

  @override
  State<DetailListModule7> createState() => _DetailListModule7State();
}

class _DetailListModule7State extends State<DetailListModule7>
    with DetailLogicConsumerMixin<DetailListModule7> {
  @override
  Widget build(BuildContext context) {
    Widget resultWidget = _buildListView();
    resultWidget = DetailListItemWrapper(
      title: 'Module 7',
      child: resultWidget,
    );
    return resultWidget;
  }

  Widget _buildListView() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.all(8),
      itemCount: 5,
      itemBuilder: (context, index) {
        return _buildListItem(index);
      },
    );
  }

  Widget _buildListItem(int index) {
    double progress = (index + 1) * 0.2;
    Widget resultWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildListItemTitle(index),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey.shade300,
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildListItemProgress(progress),
            _buildListItemStatus(progress),
          ],
        ),
      ],
    );
    resultWidget = Padding(
      padding: const EdgeInsets.all(16.0),
      child: resultWidget,
    );
    resultWidget = Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: resultWidget,
    );
    return resultWidget;
  }

  Widget _buildListItemStatus(double progress) {
    return Text(
      progress < 1.0 ? 'In Progress' : 'Completed',
      style: TextStyle(
        color: progress < 1.0 ? Colors.orange : Colors.green,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildListItemProgress(double progress) {
    return Text(
      '${(progress * 100).toInt()}% Done',
      style: const TextStyle(
        color: Colors.grey,
        fontSize: 14,
      ),
    );
  }

  Widget _buildListItemTitle(int index) {
    return Text(
      'Task ${index + 1}: Data Sync',
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    );
  }
}
