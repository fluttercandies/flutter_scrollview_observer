/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/LinXunFeng/flutter_scrollview_observer
 * @Date: 2022-08-21 00:53:44
 */

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:scrollview_observer/src/common/models/observe_model.dart';
import 'package:scrollview_observer/src/gridview/models/gridview_observe_displaying_child_model.dart';
import 'package:scrollview_observer/src/gridview/models/gridview_observe_model.dart';
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
    required ObserveModel observeModel,
    required List<int> tabIndexs,
    required int currentTabIndex,
  }) {
    if (currentTabIndex >= tabIndexs.length) {
      return currentTabIndex;
    }
    if (observeModel is ListViewObserveModel) {
      final topIndex = observeModel.firstChild?.index ?? 0;
      final index = tabIndexs.indexOf(topIndex);
      if (isValidListIndex(index)) {
        return index;
      }
      var targetTabIndex = currentTabIndex - 1;
      if (targetTabIndex < 0 || targetTabIndex >= tabIndexs.length) {
        return currentTabIndex;
      }
      var curIndex = tabIndexs[currentTabIndex];
      var lastIndex = tabIndexs[currentTabIndex - 1];
      if (curIndex > topIndex && lastIndex < topIndex) {
        final lastTabIndex = tabIndexs.indexOf(lastIndex);
        if (isValidListIndex(lastTabIndex)) {
          return lastTabIndex;
        }
      }
    } else if (observeModel is GridViewObserveModel) {
      final firstGroupChildList = observeModel.firstGroupChildList;
      if (firstGroupChildList.isEmpty) {
        return currentTabIndex;
      }
      // Record the child with the shortest distance from the bottom.
      GridViewObserveDisplayingChildModel mainChildModel =
          firstGroupChildList.first;
      for (var firstGroupChildModel in firstGroupChildList) {
        final index = tabIndexs.indexOf(firstGroupChildModel.index);
        if (isValidListIndex(index)) {
          // Found the target index from tabIndexs, return directly.
          return index;
        }
        if (mainChildModel.trailingMarginToViewport <
            firstGroupChildModel.trailingMarginToViewport) {
          mainChildModel = firstGroupChildModel;
        }
      }
      // Target index not found from tabIndexs.
      var targetTabIndex = currentTabIndex - 1;
      if (targetTabIndex < 0 || targetTabIndex >= tabIndexs.length) {
        return currentTabIndex;
      }
      var curIndex = tabIndexs[currentTabIndex];
      final firstGroupIndexList =
          firstGroupChildList.map((e) => e.index).toList();
      final minOffset = mainChildModel.layoutOffset;
      final maxOffset =
          mainChildModel.layoutOffset + mainChildModel.mainAxisSize;
      final displayingChildModelList =
          observeModel.displayingChildModelList.where((e) {
        return !firstGroupIndexList.contains(e.index) &&
            e.layoutOffset >= minOffset &&
            e.layoutOffset <= maxOffset;
      }).toList();
      // If the indexes of all the children currently being displayed are
      // greater than curIndex, keep using currentTabIndex.
      // Otherwise, using targetTabIndex.
      for (var model in displayingChildModelList) {
        if (model.index <= curIndex) {
          return targetTabIndex;
        }
      }
    }
    return currentTabIndex;
  }

  /// Determines whether the offset at the bottom of the target child widget
  /// is below the specified offset.
  static bool isBelowOffsetWidgetInSliver({
    required double scrollViewOffset,
    required Axis scrollDirection,
    required RenderBox targetChild,
    double toNextOverPercent = 1,
  }) {
    if (targetChild is! RenderIndexedSemantics) return false;
    if (!targetChild.hasSize) return false;
    final parentData = targetChild.parentData;
    if (parentData is! SliverMultiBoxAdaptorParentData) {
      return false;
    }
    final targetFirstChildOffset = parentData.layoutOffset ?? 0;
    final double targetFirstChildSize;
    try {
      // In some cases, getting size may throw an exception.
      targetFirstChildSize = scrollDirection == Axis.vertical
          ? targetChild.size.height
          : targetChild.size.width;
    } catch (_) {
      return false;
    }
    return scrollViewOffset <
        targetFirstChildSize * toNextOverPercent + targetFirstChildOffset;
  }

  /// Determines whether the target child widget has reached the specified
  /// offset
  static bool isReachOffsetWidgetInSliver({
    required double scrollViewOffset,
    required Axis scrollDirection,
    required RenderBox targetChild,
    double toNextOverPercent = 1,
  }) {
    if (!isBelowOffsetWidgetInSliver(
      scrollViewOffset: scrollViewOffset,
      scrollDirection: scrollDirection,
      targetChild: targetChild,
      toNextOverPercent: toNextOverPercent,
    )) return false;
    final parentData = targetChild.parentData;
    if (parentData is! SliverMultiBoxAdaptorParentData) {
      return false;
    }
    final targetFirstChildOffset = parentData.layoutOffset ?? 0;
    return scrollViewOffset >= targetFirstChildOffset;
  }

  /// Determines whether the target child widget is being displayed
  static bool isDisplayingChildInSliver({
    required RenderBox? targetChild,
    required double showingChildrenMaxOffset,
    required double scrollViewOffset,
    required Axis scrollDirection,
    double toNextOverPercent = 1,
  }) {
    if (targetChild == null) {
      return false;
    }
    if (!isBelowOffsetWidgetInSliver(
      scrollViewOffset: scrollViewOffset,
      scrollDirection: scrollDirection,
      targetChild: targetChild,
      toNextOverPercent: toNextOverPercent,
    )) {
      return false;
    }
    final parentData = targetChild.parentData;
    if (parentData is! SliverMultiBoxAdaptorParentData) {
      return false;
    }
    final targetChildLayoutOffset = parentData.layoutOffset ?? 0;
    return targetChildLayoutOffset < showingChildrenMaxOffset;
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
