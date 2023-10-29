/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/fluttercandies/flutter_scrollview_observer
 * @Date: 2023-10-28 19:43:04
 */
import 'package:flutter/material.dart';

class AzListItemView extends StatelessWidget {
  const AzListItemView({
    Key? key,
    required this.name,
    this.isShowSeparator = true,
  }) : super(key: key);

  final String name;

  final bool isShowSeparator;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          border: isShowSeparator
              ? Border(
                  bottom: BorderSide(
                    color: Colors.grey[300]!,
                    width: 0.5,
                  ),
                )
              : null,
        ),
        alignment: Alignment.centerLeft,
        margin: const EdgeInsets.only(left: 16.0),
        child: Text(
          name,
          style: const TextStyle(color: Colors.black),
        ),
      ),
    );
  }
}
