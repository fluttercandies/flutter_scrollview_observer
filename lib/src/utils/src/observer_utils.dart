/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/LinXunFeng/flutter_scrollview_observer
 * @Date: 2022-08-21 00:53:44
 */

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:scrollview_observer/src/common/models/observe_model.dart';
import 'package:scrollview_observer/src/gridview/models/gridview_observe_displaying_child_model.dart';
import 'package:scrollview_observer/src/gridview/models/gridview_observe_model.dart';
import 'package:scrollview_observer/src/listview/models/listview_observe_model.dart';
import 'package:scrollview_observer/src/utils/src/log.dart';
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
    final obj = ObserverUtils.findRenderObject(ctx);
    if (obj is! RenderSliverPersistentHeader) return 0;
    final maxExtent = obj.maxExtent;
    final minExtent = obj.minExtent;
    final currentExtent = math.max(minExtent, maxExtent - offset);
    return currentExtent;
  }

  /// Calculate the anchor tab index.
  static int calcAnchorTabIndex({
    required ObserveModel observeModel,
    @Deprecated(
      'It will be removed in version 2, please use [tabIndexes] instead',
    )
    List<int>? tabIndexs,
    List<int>? tabIndexes,
    required int currentTabIndex,
  }) {
    assert(
      tabIndexs != null || tabIndexes != null,
      'tabIndexes and tabIndexs cannot both be null.',
    );
    List<int> indexes = tabIndexes ?? tabIndexs ?? [];
    if (currentTabIndex >= indexes.length) {
      return currentTabIndex;
    }
    if (observeModel is ListViewObserveModel) {
      return calcAnchorTabIndexForList(
        firstIndex: observeModel.firstChild?.index,
        tabIndexes: indexes,
        currentTabIndex: currentTabIndex,
      );
    } else if (observeModel is GridViewObserveModel) {
      final firstGroupChildList = observeModel.firstGroupChildList;
      if (firstGroupChildList.isEmpty) {
        return currentTabIndex;
      }
      // Record the child with the shortest distance from the bottom.
      GridViewObserveDisplayingChildModel mainChildModel =
          firstGroupChildList.first;
      for (var firstGroupChildModel in firstGroupChildList) {
        final index = indexes.indexOf(firstGroupChildModel.index);
        if (isValidListIndex(index)) {
          // Found the target index from indexes, return directly.
          return index;
        }
        if (mainChildModel.trailingMarginToViewport <
            firstGroupChildModel.trailingMarginToViewport) {
          mainChildModel = firstGroupChildModel;
        }
      }
      // Target index not found from indexes.
      var targetTabIndex = currentTabIndex - 1;
      if (targetTabIndex < 0 || targetTabIndex >= indexes.length) {
        return currentTabIndex;
      }
      var curIndex = indexes[currentTabIndex];
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

  /// Calculate the anchor tab index for list type.
  ///
  /// - [firstIndex] is the index of the first child widget.
  /// - [tabIndexes] is the list of indexes of all tabs.
  /// - [currentTabIndex] is the current tab index.
  static int calcAnchorTabIndexForList({
    int? firstIndex,
    required List<int> tabIndexes,
    required int currentTabIndex,
  }) {
    // Example:
    // ====== exact match ======
    // tabIndexes: [0, 6, 9, 11, 12, 16]
    // firstIndex: 12
    // result: 4 (the index of 12 in tabIndexes)
    //
    //  ====== no exact match ======
    // tabIndexes: [0, 6, 9, 11, 12, 16]
    // firstIndex: 10
    // result: 2 (the index of 9 in tabIndexes)

    if (tabIndexes.isEmpty) return currentTabIndex;
    if (firstIndex == null) return currentTabIndex;
    final target = firstIndex;
    // If the target value is less than the minimum value, currentTabIndex is
    // returned.
    if (target < tabIndexes.first) return currentTabIndex;
    // If the target value is greater than or equal to the maximum value, the
    // maximum value is returned.
    if (target >= tabIndexes.last) return tabIndexes.length - 1;

    // Two-point search
    int left = 0;
    int right = tabIndexes.length - 1;
    // The currentTabIndex is returned by default.
    int resultIndex = currentTabIndex;

    while (left <= right) {
      int mid = (left + right) ~/ 2;
      int midValue = tabIndexes[mid];

      if (midValue == target) {
        // Find an equal value and return its index.
        return mid;
      } else if (midValue < target) {
        // Update the index of elements with the largest less than the target
        // value.
        resultIndex = mid;
        left = mid + 1;
      } else {
        right = mid - 1;
      }
    }
    return resultIndex;
  }

  /// Determines whether the offset at the bottom of the target child widget
  /// is below the specified offset.
  static bool isBelowOffsetWidgetInSliver({
    required double scrollViewOffset,
    required Axis scrollDirection,
    required RenderBox targetChild,
    double toNextOverPercent = 1,
  }) {
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
    )) {
      return false;
    }
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
    // Starting from flutter version 3.13.0, the type of parent received
    // is RenderObject, while the type of the previous version is AbstractNode,
    // but RenderObject is a subclass of AbstractNode, so for compatibility,
    // we can use RenderObject.
    var parent = obj.parent;
    if (parent is! RenderObject) {
      return null;
    }
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
    if (!(sliver.geometry?.visible ?? false)) {
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

  /// Safely call findRenderObject method.
  static RenderObject? findRenderObject(BuildContext? context) {
    bool isMounted = context?.mounted ?? false;
    if (!isMounted) {
      return null;
    }
    try {
      // It throws an exception when getting renderObject of inactive element.
      return context?.findRenderObject();
    } catch (e) {
      Log.warning('Cannot get renderObject of inactive element.\n'
          'Please call the reattach method of ObserverController to re-record '
          'BuildContext.');
      return null;
    }
  }

  /// Walks the children of this context.
  static BuildContext? findChildContext({
    required BuildContext context,
    required bool Function(Element) isTargetType,
  }) {
    BuildContext? childContext;
    void visitor(Element element) {
      if (isTargetType(element)) {
        /// Find the target child BuildContext
        childContext = element;
        return;
      }
      element.visitChildren(visitor);
    }

    try {
      // https://github.com/fluttercandies/flutter_scrollview_observer/issues/35
      context.visitChildElements(visitor);
    } catch (e) {
      Log.warning(
        'This widget has been unmounted, so the State no longer has a context (and should be considered defunct). \n'
        'Consider canceling any active work during "dispose" or using the "mounted" getter to determine if the State is still active.',
      );
    }
    return childContext;
  }

  /// Convert the given point from the local coordinate system for this context
  /// to the global coordinate system in logical pixels.
  ///
  /// If `ancestor` is non-null, this function converts the given point to the
  /// coordinate system of `ancestor` (which must be an ancestor of this render
  /// object of context) instead of to the global coordinate system.
  ///
  /// This method is implemented in terms of [getTransformTo]. If the transform
  /// matrix puts the given `point` on the line at infinity (for instance, when
  /// the transform matrix is the zero matrix), this method returns (NaN, NaN).
  static Offset? localToGlobal({
    required BuildContext context,
    required Offset point,
    BuildContext? ancestor,
  }) {
    final renderObject = findRenderObject(context);
    if (renderObject == null) return null;
    return MatrixUtils.transformPoint(
      renderObject.getTransformTo(findRenderObject(ancestor)),
      point,
    );
  }

  /// Safely obtain [RenderSliver.constraints].
  static SliverConstraints? sliverConstraints(
    RenderSliver sliver,
  ) {
    SliverConstraints? _constraints;
    try {
      _constraints = sliver.constraints;
    } catch (e) {
      Log.warning(
        'A RenderObject does not have any constraints before it has been laid out.',
      );
    }
    return _constraints;
  }
}
