import 'package:flutter/rendering.dart';

class ListViewObserveDisplayingChildModel {
  /// The target sliverList
  RenderSliverList sliverList;

  /// The index of child widget.
  final int index;

  /// The renderObject [RenderBox] of child widget.
  final RenderBox renderObject;

  /// The axis of sliverList
  Axis get axis => sliverList.constraints.axis;

  /// The size of child
  Size get size => renderObject.size;

  /// The size of child on the main axis
  double get mainAxisSize => axis == Axis.vertical ? size.height : size.width;

  /// The scroll offset of sliverList
  double get scrollOffset => sliverList.constraints.scrollOffset;

  /// The display percentage of the current widget
  double get displayPercentage => calculateDisplayPercentage();

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

  /// Calculates the display percentage of the current widget
  double calculateDisplayPercentage() {
    final parentData = renderObject.parentData;
    if (parentData is! SliverMultiBoxAdaptorParentData) return 0;

    final currentChildLayoutOffset = parentData.layoutOffset ?? 0;
    double remainingMainAxisSize = mainAxisSize;
    if (scrollOffset > currentChildLayoutOffset) {
      remainingMainAxisSize =
          mainAxisSize - (scrollOffset - currentChildLayoutOffset);
    } else {
      final childWidgetMaxY = mainAxisSize + currentChildLayoutOffset;
      final listContentMaxY =
          scrollOffset + sliverList.constraints.remainingPaintExtent;
      if (childWidgetMaxY > listContentMaxY) {
        remainingMainAxisSize =
            mainAxisSize - (childWidgetMaxY - listContentMaxY);
      }
    }
    return (remainingMainAxisSize / mainAxisSize).clamp(0, 1);
  }
}
