import 'package:flutter/rendering.dart';

class ListViewObserveDisplayingChildModel {
  /// The target sliverList
  RenderSliverList sliverList;

  /// The index of child widget.
  final int index;

  /// The renderObject [RenderBox] of child widget.
  final RenderBox renderObject;

  /// Size of child
  Size get size => renderObject.size;

  ListViewObserveDisplayingChildModel({
    required this.sliverList,
    required this.index,
    required this.renderObject,
  });

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
