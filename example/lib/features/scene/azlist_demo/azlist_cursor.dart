/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/fluttercandies/flutter_scrollview_observer
 * @Date: 2023-10-28 15:56:01

 */
import 'package:flutter/material.dart';

class AzListCursor extends StatelessWidget {
  final double size;

  final String title;

  final double arrowSize = 30;

  const AzListCursor({
    Key? key,
    required this.size,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _buildTitle(),
        Positioned(
          right: -arrowSize * 0.5 - 2.5,
          top: (size - arrowSize) * 0.5,
          child: _buildArrow(),
        ),
      ],
    );
  }

  Widget _buildArrow() {
    Widget resultWidget = Icon(
      Icons.arrow_right,
      color: Colors.black54,
      size: arrowSize,
    );
    return resultWidget;
  }

  Widget _buildTitle() {
    Widget resultWidget = Text(
      title,
      style: const TextStyle(color: Colors.white, fontSize: 32),
    );
    resultWidget = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(5),
      ),
      child: resultWidget,
    );
    return resultWidget;
  }
}
