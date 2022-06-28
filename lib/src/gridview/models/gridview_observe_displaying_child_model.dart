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
  RenderSliverGrid sliverGrid;

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
