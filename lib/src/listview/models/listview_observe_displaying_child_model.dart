import 'package:flutter/rendering.dart';
import 'package:scrollview_observer/src/common/models/observe_displaying_child_model.dart';
import 'package:scrollview_observer/src/common/models/observe_displaying_child_model_mixin.dart';

class ListViewObserveDisplayingChildModel extends ObserveDisplayingChildModel
    with ObserveDisplayingChildModelMixin {
  ListViewObserveDisplayingChildModel({
    required this.sliverList,
    required int index,
    required RenderBox renderObject,
  }) : super(sliver: sliverList, index: index, renderObject: renderObject);

  // The target sliverList
  RenderSliverList sliverList;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is ListViewObserveDisplayingChildModel) {
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
