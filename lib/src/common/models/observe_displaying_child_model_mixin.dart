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

  /// The amount of currently visible visual space to the [sliver].
  double get paintExtent => sliver.geometry?.paintExtent ?? 0;

  /// The precedingScrollExtent of sliver
  ///
  /// Note: Before Flutter 3.22.0, this value may be inaccurate in some scenarios.
  /// Related PR: https://github.com/flutter/flutter/pull/143661
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

  /// The number of pixels to offset the children in the opposite of the axis
  /// direction.
  double get viewportPixels =>
      viewport.offset.hasPixels ? viewport.offset.pixels : 0;

  /// The margin from the top of the child widget to the viewport.
  double get leadingMarginToViewport =>
      layoutOffset + precedingScrollExtent - viewportPixels;

  /// The margin from the bottom of the child widget to the viewport.
  double get trailingMarginToViewport =>
      viewportMainAxisExtent - leadingMarginToViewport - mainAxisSize;

  /// The visible size of the child widget in the main axis.
  double get visibleMainAxisSize {
    if (paintExtent == 0) return 0;
    double _visibleMainAxisSize = mainAxisSize;
    final currentChildLayoutOffset = layoutOffset;
    final scrollOffset = sliver.constraints.scrollOffset;
    final leadingScrollViewOffset = scrollOffset + overlap;
    if (leadingScrollViewOffset > currentChildLayoutOffset) {
      // The child widget is blocked by the leading direction side of viewport.
      _visibleMainAxisSize =
          mainAxisSize - (leadingScrollViewOffset - currentChildLayoutOffset);
    } else if (scrollOffset + paintExtent >
        currentChildLayoutOffset + mainAxisSize) {
      // The child widget is being fully displayed.
      _visibleMainAxisSize = mainAxisSize;
    } else {
      // The child widget is blocked by the trailing direction side of viewport.
      _visibleMainAxisSize =
          scrollOffset + paintExtent - currentChildLayoutOffset;
    }
    _visibleMainAxisSize = _visibleMainAxisSize.clamp(0, mainAxisSize);
    return _visibleMainAxisSize;
  }

  /// The visible fraction of the child widget on the corresponding sliver.
  double get visibleFraction {
    if (paintExtent == 0) return 0;
    return (visibleMainAxisSize / paintExtent).clamp(0, 1);
  }

  /// The display percentage of the current widget
  double get displayPercentage {
    if (mainAxisSize == 0) return 0;
    return (visibleMainAxisSize / mainAxisSize).clamp(0, 1);
  }
}
