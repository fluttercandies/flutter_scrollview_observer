import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'models/listview_observe_model.dart';
import 'models/listview_observe_displaying_child_model.dart';
import 'notification.dart';

class ListViewObserver extends StatefulWidget {
  final Widget child;

  /// The callback of getting all sliverList's buildContext.
  final List<BuildContext> Function() sliverListContexts;

  /// The callback of geting observed result map.
  final Function(Map<BuildContext, ListViewObserveModel>) onObserve;

  /// Calculate offset.
  final double leadingOffset;

  /// Calculate offset dynamically
  /// If this callback is implemented, the [leadingOffset] property will be 
  /// invalid.
  final double Function()? dynamicLeadingOffset;

  /// Looking for the next child widget when the current child widget itself
  /// shows more than this percentage.
  final double toNextOverPercent;

  const ListViewObserver({
    Key? key,
    required this.child,
    required this.sliverListContexts,
    required this.onObserve,
    this.leadingOffset = 0,
    this.dynamicLeadingOffset,
    this.toNextOverPercent = 1,
  })  : assert(toNextOverPercent > 0 && toNextOverPercent <= 1),
        super(key: key);

  @override
  State<ListViewObserver> createState() => _ListViewObserverState();
}

class _ListViewObserverState extends State<ListViewObserver> {
  /// The last observation result
  Map<BuildContext, ListViewObserveModel> lastResultMap = {};

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ListViewOnceObserveNotification>(
      onNotification: (_) {
        _handleContexts();
        return true;
      },
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          _handleContexts();
          return false;
        },
        child: widget.child,
      ),
    );
  }

  /// Handle all buildContext
  _handleContexts() {
    final sliverListContexts = widget.sliverListContexts;
    var ctxs = sliverListContexts();
    Map<BuildContext, ListViewObserveModel> resultMap = {};
    Map<BuildContext, ListViewObserveModel> changeResultMap = {};
    for (var ctx in ctxs) {
      final targetObserveModel = _handleObserve(ctx);
      if (targetObserveModel == null) continue;
      resultMap[ctx] = targetObserveModel;

      final lastResultModel = lastResultMap[ctx];
      if (lastResultModel == null) {
        changeResultMap[ctx] = targetObserveModel;
      } else if (lastResultModel != targetObserveModel) {
        changeResultMap[ctx] = targetObserveModel;
      }
    }

    lastResultMap = resultMap;

    if (changeResultMap.isNotEmpty) {
      widget.onObserve(changeResultMap);
    }
  }

  ListViewObserveModel? _handleObserve(BuildContext ctx) {
    final _obj = ctx.findRenderObject();
    if (_obj is! RenderSliverList) return null;
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

    // find out the first child which is displaying
    var targetFirstChild = firstChild;
    var targetFistChildData =
        targetFirstChild.parentData as SliverMultiBoxAdaptorParentData;

    while (listViewOffset >
        targetFirstChild.size.height * widget.toNextOverPercent +
            (targetFistChildData.layoutOffset ?? 0)) {
      index = index + 1;
      var nextChild = _obj.childAfter(targetFirstChild);
      if (nextChild == null) break;

      if (nextChild is! RenderIndexedSemantics) {
        // it is separator
        nextChild = _obj.childAfter(nextChild);
      }
      if (nextChild == null) break;
      targetFirstChild = nextChild;
      targetFistChildData =
          targetFirstChild.parentData as SliverMultiBoxAdaptorParentData;
    }
    if (targetFirstChild is! RenderIndexedSemantics) return null;

    List<ListViewObserveDisplayingChildModel> showingChildModelList = [];
    showingChildModelList.add(ListViewObserveDisplayingChildModel(
      index: targetFirstChild.index,
      renderObject: targetFirstChild,
    ));

    // find the remaining children that are being displayed
    var listViewBottomOffset =
        rawListViewOffset + _obj.constraints.remainingPaintExtent;
    var showingChild = _obj.childAfter(targetFirstChild);
    while (showingChild != null &&
        showingChild.parentData is SliverMultiBoxAdaptorParentData &&
        ((showingChild.parentData as SliverMultiBoxAdaptorParentData)
                    .layoutOffset ??
                0) <
            listViewBottomOffset) {
      if (showingChild is! RenderIndexedSemantics) {
        showingChild = _obj.childAfter(showingChild);
        continue;
      }
      showingChildModelList.add(ListViewObserveDisplayingChildModel(
        index: showingChild.index,
        renderObject: showingChild,
      ));
      showingChild = _obj.childAfter(showingChild);
    }

    return ListViewObserveModel(
      firstChild: ListViewObserveDisplayingChildModel(
        index: targetFirstChild.index,
        renderObject: targetFirstChild,
      ),
      showingChildModelList: showingChildModelList,
    );
  }
}
