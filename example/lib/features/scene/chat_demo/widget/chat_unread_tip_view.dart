/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/LinXunFeng/flutter_scrollview_observer
 * @Date: 2022-10-31 15:40:04
 */

import 'package:flutter/material.dart';

class ChatUnreadTipView extends StatelessWidget {
  ChatUnreadTipView({
    Key? key,
    required this.unreadMsgCount,
    this.onTap,
  }) : super(key: key);

  final int unreadMsgCount;

  final Color primaryColor = Colors.green[100]!;

  final GestureTapCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (unreadMsgCount == 0) return const SizedBox.shrink();
    Widget resultWidget = Stack(
      children: [
        const Icon(
          Icons.mode_comment,
          size: 50,
          color: Colors.white,
        ),
        Container(
          margin: const EdgeInsets.only(top: 12),
          width: 50,
          child: Center(
            child: Text(
              '$unreadMsgCount',
              style: const TextStyle(
                color: Colors.blue,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
    resultWidget = GestureDetector(
      child: resultWidget,
      onTap: onTap,
    );
    return resultWidget;
  }
}
