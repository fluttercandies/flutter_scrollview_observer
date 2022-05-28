import 'package:flutter/material.dart';

class ListViewObserveDisplayingChildModel {
  /// 下标
  final int index;

  /// Render对象
  final RenderBox renderObject;

  ListViewObserveDisplayingChildModel({
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
