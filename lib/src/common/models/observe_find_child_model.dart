/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/LinXunFeng/flutter_scrollview_observer
 * @Date: 2022-09-26 23:05:33
 */

import 'package:flutter/rendering.dart';

/// [ObserveFindChildModel] is used to pass data internally.
class ObserveFindChildModel {
  ObserveFindChildModel({
    required this.sliver,
    required this.viewport,
    required this.index,
    required this.renderObject,
  });

  /// The target sliverList.
  RenderSliver sliver;

  /// The viewport of sliver.
  RenderViewportBase viewport;

  /// The index of child widget.
  int index;

  /// The renderObject [RenderIndexedSemantics] of child widget.
  RenderIndexedSemantics renderObject;
}
