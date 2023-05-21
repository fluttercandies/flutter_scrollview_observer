/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/LinXunFeng/flutter_scrollview_observer
 * @Date: 2023-05-20 15:38:28
 */
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'gridview/models/gridview_observe_displaying_child_model.dart';
import 'gridview/models/gridview_observe_model.dart';
import 'listview/models/listview_observe_displaying_child_model.dart';
import 'listview/models/listview_observe_model.dart';
import 'utils/observer_utils.dart';

class ObserverCore {
  /// Handles observation logic of a sliver similar to [SliverList].
  static ListViewObserveModel? handleListObserve({
    required BuildContext context,
    double Function()? fetchLeadingOffset,
    double toNextOverPercent = 1,
  }) {
    var _obj = context.findRenderObject();
    if (_obj is! RenderSliverMultiBoxAdaptor) return null;
    if (kDebugMode) {
      final viewport = ObserverUtils.findViewport(_obj);
      if (viewport == null) return null;
      if (viewport.debugNeedsPaint) return null;
    }
    if (!(_obj.geometry?.visible ?? true)) {
      return ListViewObserveModel(
        sliverList: _obj,
        visible: false,
        firstChild: null,
        displayingChildModelList: [],
      );
    }
    final scrollDirection = _obj.constraints.axis;
    var firstChild = _obj.firstChild;
    if (firstChild == null) return null;

    final offset = fetchLeadingOffset?.call() ?? 0;
    final rawListViewOffset =
        _obj.constraints.scrollOffset + _obj.constraints.overlap;
    var listViewOffset = rawListViewOffset + offset;
    var parentData = firstChild.parentData as SliverMultiBoxAdaptorParentData;
    var index = parentData.index ?? 0;

    // Find out the first child which is displaying
    var targetFirstChild = firstChild;

    while (!ObserverUtils.isBelowOffsetWidgetInSliver(
      listViewOffset: listViewOffset,
      scrollDirection: scrollDirection,
      targetChild: targetFirstChild,
      toNextOverPercent: toNextOverPercent,
    )) {
      index = index + 1;
      var nextChild = _obj.childAfter(targetFirstChild);
      if (nextChild == null) break;

      if (nextChild is! RenderIndexedSemantics) {
        // It is separator
        nextChild = _obj.childAfter(nextChild);
      }
      if (nextChild == null) break;
      targetFirstChild = nextChild;
    }
    if (targetFirstChild is! RenderIndexedSemantics) return null;

    List<ListViewObserveDisplayingChildModel> displayingChildModelList = [
      ListViewObserveDisplayingChildModel(
        sliverList: _obj,
        index: targetFirstChild.index,
        renderObject: targetFirstChild,
      ),
    ];

    // Find the remaining children that are being displayed
    final listViewBottomOffset =
        rawListViewOffset + _obj.constraints.remainingPaintExtent;
    var displayingChild = _obj.childAfter(targetFirstChild);
    while (ObserverUtils.isDisplayingChildInSliver(
      targetChild: displayingChild,
      listViewBottomOffset: listViewBottomOffset,
    )) {
      if (displayingChild == null) {
        break;
      }
      if (displayingChild is! RenderIndexedSemantics) {
        // It is separator
        displayingChild = _obj.childAfter(displayingChild);
        continue;
      }
      displayingChildModelList.add(ListViewObserveDisplayingChildModel(
        sliverList: _obj,
        index: displayingChild.index,
        renderObject: displayingChild,
      ));
      displayingChild = _obj.childAfter(displayingChild);
    }

    return ListViewObserveModel(
      sliverList: _obj,
      visible: true,
      firstChild: ListViewObserveDisplayingChildModel(
        sliverList: _obj,
        index: targetFirstChild.index,
        renderObject: targetFirstChild,
      ),
      displayingChildModelList: displayingChildModelList,
    );
  }

  /// Handles observation logic of a sliver similar to [SliverGrid].
  static GridViewObserveModel? handleGridObserve({
    required BuildContext context,
    double Function()? fetchLeadingOffset,
    double toNextOverPercent = 1,
  }) {
    final _obj = context.findRenderObject();
    if (_obj is! RenderSliverMultiBoxAdaptor) return null;
    if (kDebugMode) {
      final viewport = ObserverUtils.findViewport(_obj);
      if (viewport == null) return null;
      if (viewport.debugNeedsPaint) return null;
    }
    if (!(_obj.geometry?.visible ?? true)) {
      return GridViewObserveModel(
        sliverGrid: _obj,
        visible: false,
        firstGroupChildList: [],
        displayingChildModelList: [],
      );
    }
    final scrollDirection = _obj.constraints.axis;
    var firstChild = _obj.firstChild;
    if (firstChild == null) return null;

    final offset = fetchLeadingOffset?.call() ?? 0;
    final rawListViewOffset =
        _obj.constraints.scrollOffset + _obj.constraints.overlap;
    var listViewOffset = rawListViewOffset + offset;

    // Find out the first child which is displaying
    var targetFirstChild = firstChild;
    var lastFirstGroupChildWidget = targetFirstChild;

    while (!ObserverUtils.isBelowOffsetWidgetInSliver(
      listViewOffset: listViewOffset,
      scrollDirection: scrollDirection,
      targetChild: targetFirstChild,
      toNextOverPercent: toNextOverPercent,
    )) {
      /// Entering here means it is not the target object
      RenderBox? nextChild = _obj.childAfter(targetFirstChild);
      if (nextChild == null) break;
      targetFirstChild = nextChild;
    }
    if (targetFirstChild is! RenderIndexedSemantics) return null;

    final firstModel = GridViewObserveDisplayingChildModel(
      sliverGrid: _obj,
      index: targetFirstChild.index,
      renderObject: targetFirstChild,
    );
    List<GridViewObserveDisplayingChildModel> firstGroupChildModelList = [];
    firstGroupChildModelList.add(firstModel);

    final listViewBottomOffset =
        rawListViewOffset + _obj.constraints.remainingPaintExtent;
    // Find out other child those have reached the specified offset.
    RenderBox? targetChild = _obj.childAfter(targetFirstChild);
    while (targetChild != null) {
      if (!ObserverUtils.isDisplayingChildInSliver(
        targetChild: targetChild,
        listViewBottomOffset: listViewBottomOffset,
      )) break;
      if (ObserverUtils.isReachOffsetWidgetInSliver(
        listViewOffset: max(listViewOffset, firstModel.layoutOffset),
        scrollDirection: scrollDirection,
        targetChild: targetChild,
        toNextOverPercent: toNextOverPercent,
      )) {
        if (targetChild is! RenderIndexedSemantics) break;
        firstGroupChildModelList.add(GridViewObserveDisplayingChildModel(
          sliverGrid: _obj,
          index: targetChild.index,
          renderObject: targetChild,
        ));
        lastFirstGroupChildWidget = targetChild;
      }

      RenderBox? nextChild = _obj.childAfter(targetChild);
      if (nextChild == null) break;
      targetChild = nextChild;
    }

    List<GridViewObserveDisplayingChildModel> showingChildModelList =
        List.from(firstGroupChildModelList);

    // Find the remaining children that are being displayed
    var displayingChild = _obj.childAfter(lastFirstGroupChildWidget);
    while (ObserverUtils.isDisplayingChildInSliver(
      targetChild: displayingChild,
      listViewBottomOffset: listViewBottomOffset,
    )) {
      if (displayingChild == null ||
          displayingChild is! RenderIndexedSemantics) {
        break;
      }
      showingChildModelList.add(GridViewObserveDisplayingChildModel(
        sliverGrid: _obj,
        index: displayingChild.index,
        renderObject: displayingChild,
      ));
      displayingChild = _obj.childAfter(displayingChild);
    }

    return GridViewObserveModel(
      sliverGrid: _obj,
      visible: true,
      firstGroupChildList: firstGroupChildModelList,
      displayingChildModelList: showingChildModelList,
    );
  }
}
