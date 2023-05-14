/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/LinXunFeng/flutter_scrollview_observer
 * @Date: 2022-08-08 00:20:03
 */
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:scrollview_observer/src/common/models/observe_model.dart';
import 'package:scrollview_observer/src/common/observer_controller.dart';
import 'package:scrollview_observer/src/common/observer_widget.dart';

import '../../scrollview_observer.dart';

mixin GridObserverMix<
        C extends ObserverController,
        M extends ObserveModel,
        N extends ScrollViewOnceObserveNotification,
        S extends RenderSliver,
        T extends ObserverWidget<C, M, N, S>>
    on ObserverWidgetState<C, M, N, S, T> {
  GridViewObserveModel? handleGridObserve(BuildContext ctx) {
    final _obj = ctx.findRenderObject();
    if (_obj is! RenderSliverGrid) return null;
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

    var offset = widget.leadingOffset;
    if (widget.dynamicLeadingOffset != null) {
      offset = widget.dynamicLeadingOffset!();
    }

    final rawListViewOffset =
        _obj.constraints.scrollOffset + _obj.constraints.overlap;
    var listViewOffset = rawListViewOffset + offset;

    // Find out the first child which is displaying
    var targetFirstChild = firstChild;
    var lastFirstGroupChildWidget = targetFirstChild;

    while (!isBelowOffsetWidget(
      listViewOffset: listViewOffset,
      scrollDirection: scrollDirection,
      targetChild: targetFirstChild,
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
      if (!isDisplayingChild(
        targetChild: targetChild,
        listViewBottomOffset: listViewBottomOffset,
      )) break;
      if (isReachOffsetWidget(
        listViewOffset: max(listViewOffset, firstModel.layoutOffset),
        scrollDirection: scrollDirection,
        targetChild: targetChild,
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
    while (isDisplayingChild(
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
