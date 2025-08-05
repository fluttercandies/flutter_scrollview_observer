/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/fluttercandies/flutter_scrollview_observer
 * @Date: 2025-08-02 21:32:26
 */

import 'package:flutter/material.dart';
import 'package:scrollview_observer_example/features/scene/detail/header/detail_header.dart';
import 'package:scrollview_observer_example/features/scene/detail/widget/detail_list_item_wrapper.dart';

class DetailListModule5 extends StatefulWidget {
  const DetailListModule5({super.key});

  @override
  State<DetailListModule5> createState() => _DetailListModule5State();
}

class _DetailListModule5State extends State<DetailListModule5>
    with DetailLogicConsumerMixin<DetailListModule5> {
  List<String> titles = [
    'Enable Notifications',
    'Dark Mode',
    'Autoplay Videos',
    'Remember Me',
    'Privacy Settings',
  ];

  List<String> subtitles = [
    'Receive app notifications',
    'Switch app theme to dark',
    'Autoplay videos on Wi-Fi',
    'Automatically log in next time',
    'Manage your privacy preferences',
  ];

  @override
  Widget build(BuildContext context) {
    Widget resultWidget = _buildListView();
    resultWidget = DetailListItemWrapper(
      title: 'Module 5',
      child: resultWidget,
    );
    return resultWidget;
  }

  Widget _buildListView() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: titles.length,
      itemBuilder: (context, index) {
        return Column(
          children: [
            _buildListItem(index),
            if (index < titles.length - 1) const Divider(height: 1),
          ],
        );
      },
    );
  }

  Widget _buildListItem(int index) {
    return ListTile(
      leading: _getLeadingIcon(index),
      title: Text(titles[index]),
      subtitle: Text(subtitles[index]),
      trailing: _getTrailingWidget(index),
    );
  }

  Widget _getLeadingIcon(int index) {
    IconData iconData;
    switch (index) {
      case 0:
        iconData = Icons.notifications;
        break;
      case 1:
        iconData = Icons.dark_mode;
        break;
      case 2:
        iconData = Icons.play_circle_fill;
        break;
      case 3:
        iconData = Icons.lock;
        break;
      case 4:
        iconData = Icons.privacy_tip;
        break;
      default:
        iconData = Icons.settings;
        break;
    }
    return Icon(iconData);
  }

  Widget _getTrailingWidget(int index) {
    return Switch(
      value: index % 2 == 0,
      onChanged: (_) {},
    );
  }
}
