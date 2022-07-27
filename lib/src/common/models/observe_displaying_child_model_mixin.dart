import 'package:flutter/rendering.dart';

import 'observe_displaying_child_model.dart';

mixin ObserveDisplayingChildModelMixin on ObserveDisplayingChildModel {
  /// The axis of sliver
  Axis get axis => sliver.constraints.axis;

  /// The size of child
  Size get size => renderObject.size;

  /// The size of child on the main axis
  double get mainAxisSize => axis == Axis.vertical ? size.height : size.width;

  /// The scroll offset of sliver
  double get scrollOffset => sliver.constraints.scrollOffset;

  /// The layout offset of child
  double get layoutOffset {
    final parentData = renderObject.parentData;
    if (parentData is! SliverLogicalParentData) return 0;
    return parentData.layoutOffset ?? 0;
  }

  /// The margin from the top of the child widget to the sliver.
  double get leadingAxisMarginToViewport => layoutOffset - scrollOffset;

  /// The margin from the bottom of the child widget to the sliver.
  double get trailingAxisMarginToViewport =>
      sliver.constraints.viewportMainAxisExtent -
      leadingAxisMarginToViewport -
      mainAxisSize;

  /// The display percentage of the current widget
  double get displayPercentage => calculateDisplayPercentage();

  /// Calculates the display percentage of the current widget
  double calculateDisplayPercentage() {
    final currentChildLayoutOffset = layoutOffset;
    double remainingMainAxisSize = mainAxisSize;
    if (scrollOffset > currentChildLayoutOffset) {
      remainingMainAxisSize =
          mainAxisSize - (scrollOffset - currentChildLayoutOffset);
    } else {
      final childWidgetMaxY = mainAxisSize + currentChildLayoutOffset;
      final listContentMaxY =
          scrollOffset + sliver.constraints.remainingPaintExtent;
      if (childWidgetMaxY > listContentMaxY) {
        remainingMainAxisSize =
            mainAxisSize - (childWidgetMaxY - listContentMaxY);
      }
    }
    return (remainingMainAxisSize / mainAxisSize).clamp(0, 1);
  }
}
