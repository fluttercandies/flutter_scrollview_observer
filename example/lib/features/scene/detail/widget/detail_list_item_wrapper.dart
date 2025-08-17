/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/fluttercandies/flutter_scrollview_observer
 * @Date: 2025-08-03 15:07:52
 */

import 'package:flutter/material.dart';
import 'package:scrollview_observer_example/features/scene/detail/header/detail_header.dart';

class DetailListItemWrapper extends StatefulWidget {
  final String? title;
  final Widget child;

  const DetailListItemWrapper({
    super.key,
    required this.child,
    this.title,
  });

  @override
  State<DetailListItemWrapper> createState() => _DetailListItemWrapperState();
}

class _DetailListItemWrapperState extends State<DetailListItemWrapper>
    with DetailLogicConsumerMixin<DetailListItemWrapper> {
  String get title => widget.title ?? '';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitle(),
        widget.child,
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildTitle() {
    if (title.isEmpty) return const SizedBox.shrink();

    Widget resultWidget = Text(
      title,
      style: Theme.of(context).textTheme.titleLarge,
    );
    resultWidget = Padding(
      padding: const EdgeInsets.only(
        top: 16,
        left: 8,
        bottom: 8,
      ),
      child: resultWidget,
    );
    return resultWidget;
  }
}
