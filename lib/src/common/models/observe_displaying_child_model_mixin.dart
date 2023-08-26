/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/LinXunFeng/flutter_scrollview_observer
 * @Date: 2022-08-08 00:20:03
 */
import 'package:flutter/rendering.dart';

import 'observe_displaying_child_model.dart';

mixin ObserveDisplayingChildModelMixin on ObserveDisplayingChildModel {
  /// The axis of sliver.
  Axis get axis => sliver.constraints.axis;

  /// The size of child widget.
  Size get size => renderObject.size;

  /// The size of child widget on the main axis.
  double get mainAxisSize => axis == Axis.vertical ? size.height : size.width;

  /// The scroll offset of sliver
  double get scrollOffset => sliver.constraints.scrollOffset;

  /// The overlap of sliver
  double get overlap => sliver.constraints.overlap;

  /// The precedingScrollExtent of sliver
  double get precedingScrollExtent => sliver.constraints.precedingScrollExtent;

  /// The layout offset of child widget.
  double get layoutOffset {
    final parentData = renderObject.parentData;
    if (parentData is! SliverLogicalParentData) return 0;
    return parentData.layoutOffset ?? 0;
  }

  /// Whether the [pixels] property of viewport is available.
  bool get viewportHasPixels => viewport.offset.hasPixels;

  /// The number of pixels the viewport can display in the main axis.
  double get viewportMainAxisExtent =>
      sliver.constraints.viewportMainAxisExtent;

  /// The number of pixels the viewport can display in the main axis.
  double get viewportPixels =>
      viewport.offset.hasPixels ? viewport.offset.pixels : 0;

  /// The margin from the top of the child widget to the viewport.
  double get leadingMarginToViewport =>
      layoutOffset + precedingScrollExtent - viewportPixels;

  /// The margin from the bottom of the child widget to the viewport.
  double get trailingMarginToViewport =>
      viewportMainAxisExtent - leadingMarginToViewport - mainAxisSize;

  /// The display percentage of the current widget
  double get displayPercentage => calculateDisplayPercentage();

  /// Calculates the display percentage of the current widget
  double calculateDisplayPercentage() {
    if (!viewportHasPixels) return 0;
    final currentChildLayoutOffset = layoutOffset + precedingScrollExtent;
    double visibleMainAxisSize = mainAxisSize;
    final rawScrollViewOffSet = viewportPixels + overlap;
    // Child widget moved out in the main axis.
    if (rawScrollViewOffSet > currentChildLayoutOffset) {
      visibleMainAxisSize =
          mainAxisSize - (rawScrollViewOffSet - currentChildLayoutOffset);
    } else {
      // The child widget is not blocked by SliverPersistentHeader at the end,
      // so [overlap] is not considered.
      visibleMainAxisSize = rawScrollViewOffSet +
          viewportMainAxisExtent -
          overlap -
          currentChildLayoutOffset;
    }
    return (visibleMainAxisSize / mainAxisSize).clamp(0, 1);
  }
}
