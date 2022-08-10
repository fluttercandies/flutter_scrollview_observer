/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Reop: https://github.com/LinXunFeng/flutter_scrollview_observer
 * @Date: 2022-08-08 00:20:03
 */
import 'package:flutter/rendering.dart';

abstract class ObserveDisplayingChildModel {
  /// The target sliverList.
  RenderSliver sliver;

  /// The index of child widget.
  int index;

  /// The renderObject [RenderBox] of child widget.
  RenderBox renderObject;

  ObserveDisplayingChildModel({
    required this.sliver,
    required this.index,
    required this.renderObject,
  });
}
