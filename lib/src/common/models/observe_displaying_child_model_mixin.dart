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

  /// The display percentage of the current widget
  double get displayPercentage => calculateDisplayPercentage();

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
          scrollOffset + sliver.constraints.remainingPaintExtent;
      if (childWidgetMaxY > listContentMaxY) {
        remainingMainAxisSize =
            mainAxisSize - (childWidgetMaxY - listContentMaxY);
      }
    }
    return (remainingMainAxisSize / mainAxisSize).clamp(0, 1);
  }
}
