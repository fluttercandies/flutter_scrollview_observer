/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/LinXunFeng/flutter_scrollview_observer
 * @Date: 2022-08-21 00:53:44
 */

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:scrollview_observer/src/listview/models/listview_observe_model.dart';
import 'dart:math' as math;

class ObserverUtils {
  ObserverUtils._();

  /// Calculate current extent of [RenderSliverPersistentHeader] base on
  /// target layout offset.
  /// Such as [SliverAppBar]
  ///
  /// You must pass either [key] or [context]
  static double calcPersistentHeaderExtent({
    GlobalKey? key,
    BuildContext? context,
    required double offset,
  }) {
    assert(key != null || context != null);
    final ctx = key?.currentContext ?? context;
    final obj = ctx?.findRenderObject();
    if (obj is! RenderSliverPersistentHeader) return 0;
    final maxExtent = obj.maxExtent;
    final minExtent = obj.minExtent;
    final currentExtent = math.max(minExtent, maxExtent - offset);
    return currentExtent;
  }

  /// Calculate the anchor tab index.
  static int calcAnchorTabIndex({
    required ListViewObserveModel observeModel,
    required List<int> tabIndexs,
    required int currentTabIndex,
  }) {
    final topIndex = observeModel.firstChild?.index ?? 0;
    final index = tabIndexs.indexOf(topIndex);
    if (index != -1) {
      return index;
    } else {
      var targetTabIndex = currentTabIndex - 1;
      if (targetTabIndex < 0 || targetTabIndex >= tabIndexs.length) {
        return currentTabIndex;
      }
      var curIndex = tabIndexs[currentTabIndex];
      var lastIndex = tabIndexs[currentTabIndex - 1];
      if (curIndex > topIndex && lastIndex < topIndex) {
        final lastTabIndex = tabIndexs.indexOf(lastIndex);
        if (lastTabIndex != -1) {
          return lastTabIndex;
        }
      }
    }
    return currentTabIndex;
  }

  /// Find out the viewport
  static RenderViewportBase? findViewport(RenderObject obj) {
    int maxCycleCount = 10;
    int currentCycleCount = 1;
    AbstractNode? parent = obj.parent;
    while (parent != null && currentCycleCount <= maxCycleCount) {
      if (parent is RenderViewportBase) {
        return parent;
      }
      parent = parent.parent;
      currentCycleCount++;
    }
    return null;
  }

  /// For viewport
  ///
  /// Determines whether the offset at the bottom of the target child widget
  /// is below the specified offset.
  static bool isBelowOffsetSliverInViewport({
    required double viewportPixels,
    RenderSliver? sliver,
  }) {
    if (sliver == null) return false;
    final layoutOffset = sliver.constraints.precedingScrollExtent;
    final size = sliver.geometry?.maxPaintExtent ?? 0;
    return viewportPixels <= layoutOffset + size;
  }

  /// For viewport
  ///
  /// Determines whether the target sliver is being displayed
  static bool isDisplayingSliverInViewport({
    required RenderSliver? sliver,
    required double viewportPixels,
    required double viewportBottomOffset,
  }) {
    if (sliver == null) {
      return false;
    }
    if (!isBelowOffsetSliverInViewport(
      viewportPixels: viewportPixels,
      sliver: sliver,
    )) {
      return false;
    }
    return sliver.constraints.precedingScrollExtent < viewportBottomOffset;
  }

  /// Determines whether it is a valid list index.
  static bool isValidListIndex(int index) {
    return index != -1;
  }
}
