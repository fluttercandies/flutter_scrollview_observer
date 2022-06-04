import 'package:flutter/material.dart';

class GridViewObserveDisplayingChildModel {
  /// The index of child widget.
  final int index;

  /// The renderObject [RenderBox] of child widget.
  final RenderBox renderObject;

  GridViewObserveDisplayingChildModel({
    required this.index,
    required this.renderObject,
  });

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
