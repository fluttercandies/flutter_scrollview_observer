/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/LinXunFeng/flutter_scrollview_observer
 * @Date: 2022-07-03 15:46:45
 */
import 'package:flutter/rendering.dart';
import 'package:scrollview_observer/src/common/models/observe_displaying_child_model.dart';
import 'package:scrollview_observer/src/common/models/observe_displaying_child_model_mixin.dart';

class GridViewObserveDisplayingChildModel extends ObserveDisplayingChildModel
    with ObserveDisplayingChildModelMixin {
  GridViewObserveDisplayingChildModel({
    required this.sliverGrid,
    required int index,
    required RenderBox renderObject,
  }) : super(sliver: sliverGrid, index: index, renderObject: renderObject);

  /// The target sliverGrid
  RenderSliverMultiBoxAdaptor sliverGrid;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is GridViewObserveDisplayingChildModel) {
      return index == other.index && renderObject == other.renderObject;
    } else {
      return false;
    }
  }

  @override
  int get hashCode {
    return index + renderObject.hashCode;
  }
}
