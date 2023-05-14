/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/LinXunFeng/flutter_scrollview_observer
 * @Date: 2022-08-08 00:20:03
 */
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:scrollview_observer/src/common/models/observe_model.dart';
import 'package:scrollview_observer/src/common/observer_controller.dart';
import 'package:scrollview_observer/src/common/observer_widget.dart';

import '../../scrollview_observer.dart';

mixin ListObserverMix<
        C extends ObserverController,
        M extends ObserveModel,
        N extends ScrollViewOnceObserveNotification,
        S extends RenderSliver,
        T extends ObserverWidget<C, M, N, S>>
    on ObserverWidgetState<C, M, N, S, T> {
  ListViewObserveModel? handleListObserve(BuildContext ctx) {
    var _obj = ctx.findRenderObject();
    if (_obj is! RenderSliverList && _obj is! RenderSliverFixedExtentList) {
      return null;
    }
    _obj = _obj as RenderSliverMultiBoxAdaptor;
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

    var offset = widget.leadingOffset;
    if (widget.dynamicLeadingOffset != null) {
      offset = widget.dynamicLeadingOffset!();
    }

    final rawListViewOffset =
        _obj.constraints.scrollOffset + _obj.constraints.overlap;
    var listViewOffset = rawListViewOffset + offset;
    var parentData = firstChild.parentData as SliverMultiBoxAdaptorParentData;
    var index = parentData.index ?? 0;

    // Find out the first child which is displaying
    var targetFirstChild = firstChild;

    while (!isBelowOffsetWidget(
      listViewOffset: listViewOffset,
      scrollDirection: scrollDirection,
      targetChild: targetFirstChild,
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
    while (isDisplayingChild(
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
}
