import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:scrollview_observer/src/notification.dart';

import 'models/gridview_observe_displaying_child_model.dart';
import 'models/gridview_observe_model.dart';

class GridViewObserver extends StatefulWidget {
  final Widget child;

  /// The callback of getting all sliverGrid's buildContext.
  final List<BuildContext> Function() sliverGridContexts;

  /// The callback of geting observed result map.
  final Function(Map<BuildContext, GridViewObserveModel>) onObserve;

  /// Calculate offset.
  final double leadingOffset;

  /// Calculate offset dynamically
  /// If this callback is implemented, the [leadingOffset] property will be
  /// invalid.
  final double Function()? dynamicLeadingOffset;

  /// After the internal logic figure out the first child widget, if the
  /// proportion of the size of the child widget blocked to its own size exceeds
  /// the value [toNextOverPercent], the next child widget will be the first
  /// child widget.
  final double toNextOverPercent;

  const GridViewObserver({
    Key? key,
    required this.child,
    required this.sliverGridContexts,
    required this.onObserve,
    this.leadingOffset = 0,
    this.dynamicLeadingOffset,
    this.toNextOverPercent = 1,
  })  : assert(toNextOverPercent > 0 && toNextOverPercent <= 1),
        super(key: key);

  @override
  State<GridViewObserver> createState() => _GridViewObserverState();
}

class _GridViewObserverState extends State<GridViewObserver> {
  /// The last observation result
  Map<BuildContext, GridViewObserveModel> lastResultMap = {};

  @override
  Widget build(BuildContext context) {
    return NotificationListener<GridViewOnceObserveNotification>(
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
    final sliverListContexts = widget.sliverGridContexts;
    var ctxs = sliverListContexts();
    Map<BuildContext, GridViewObserveModel> resultMap = {};
    Map<BuildContext, GridViewObserveModel> changeResultMap = {};
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

  GridViewObserveModel? _handleObserve(BuildContext ctx) {
    final _obj = ctx.findRenderObject();
    if (_obj is! RenderSliverGrid) return null;
    if (!(_obj.geometry?.visible ?? true)) {
      return GridViewObserveModel(
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
    var parentData = firstChild.parentData as SliverMultiBoxAdaptorParentData;
    var index = parentData.index ?? 0;

    // Find out the first child which is displaying
    var targetFirstChild = firstChild;
    var lastFirstGroupChildWidget = targetFirstChild;

    while (!_isTargetFirstWidget(
      listViewOffset: listViewOffset,
      scrollDirection: scrollDirection,
      targetFirstChild: targetFirstChild,
    )) {
      /// Entering here means it is not the target object
      /// Exclude child widgets with the same offset
      var isFindingSameOffset = true;
      index = index + 1;
      RenderBox? nextChild = _obj.childAfter(targetFirstChild);
      while (isFindingSameOffset) {
        if (nextChild == null) break;

        final targetFirstChildParentData =
            targetFirstChild.parentData as SliverMultiBoxAdaptorParentData;
        final targetFirstChildOffset =
            targetFirstChildParentData.layoutOffset ?? 0;

        final nextChildParentData =
            nextChild.parentData as SliverMultiBoxAdaptorParentData;
        final nextChildOffset = nextChildParentData.layoutOffset ?? 0;

        if (targetFirstChildOffset == nextChildOffset) {
          index++;
          nextChild = _obj.childAfter(nextChild);
          continue;
        }

        targetFirstChild = nextChild;
        isFindingSameOffset = false;
      }

      if (nextChild == null) break;
    }
    if (targetFirstChild is! RenderIndexedSemantics) return null;

    List<GridViewObserveDisplayingChildModel> firstGroupChildModelList = [
      GridViewObserveDisplayingChildModel(
        index: targetFirstChild.index,
        renderObject: targetFirstChild,
      ),
    ];

    var isFindingSameOffset = true;
    index = index + 1;
    RenderBox? nextChild = _obj.childAfter(targetFirstChild);
    while (isFindingSameOffset) {
      if (nextChild == null || nextChild is! RenderIndexedSemantics) break;

      final targetFirstChildParentData =
          targetFirstChild.parentData as SliverMultiBoxAdaptorParentData;
      final targetFirstChildOffset =
          targetFirstChildParentData.layoutOffset ?? 0;

      final nextChildParentData =
          nextChild.parentData as SliverMultiBoxAdaptorParentData;
      final nextChildOffset = nextChildParentData.layoutOffset ?? 0;

      if (targetFirstChildOffset != nextChildOffset) {
        break;
      }

      firstGroupChildModelList.add(GridViewObserveDisplayingChildModel(
        index: nextChild.index,
        renderObject: nextChild,
      ));
      lastFirstGroupChildWidget = nextChild;

      // Find next widget
      index = index + 1;
      nextChild = _obj.childAfter(nextChild);
    }

    List<GridViewObserveDisplayingChildModel> showingChildModelList =
        List.from(firstGroupChildModelList);

    // Find the remaining children that are being displayed
    final listViewBottomOffset =
        rawListViewOffset + _obj.constraints.remainingPaintExtent;
    var displayingChild = _obj.childAfter(lastFirstGroupChildWidget);
    while (_isDisplayingChild(
      targetChild: displayingChild,
      listViewBottomOffset: listViewBottomOffset,
    )) {
      if (displayingChild == null ||
          displayingChild is! RenderIndexedSemantics) {
        break;
      }
      showingChildModelList.add(GridViewObserveDisplayingChildModel(
        index: displayingChild.index,
        renderObject: displayingChild,
      ));
      displayingChild = _obj.childAfter(displayingChild);
    }

    return GridViewObserveModel(
      visible: true,
      firstGroupChildList: firstGroupChildModelList,
      displayingChildModelList: showingChildModelList,
    );
  }

  /// Determines whether the target child widget is the first widget being
  /// displayed
  bool _isTargetFirstWidget({
    required double listViewOffset,
    required Axis scrollDirection,
    required RenderBox targetFirstChild,
  }) {
    final parentData = targetFirstChild.parentData;
    if (parentData is! SliverMultiBoxAdaptorParentData) {
      return false;
    }
    final targetFirstChildOffset = parentData.layoutOffset ?? 0;
    final targetFirstChildSize = scrollDirection == Axis.vertical
        ? targetFirstChild.size.height
        : targetFirstChild.size.width;
    return listViewOffset <=
        targetFirstChildSize * widget.toNextOverPercent +
            targetFirstChildOffset;
  }

  /// Determines whether the target child widget is being displayed
  bool _isDisplayingChild({
    required RenderBox? targetChild,
    required double listViewBottomOffset,
  }) {
    if (targetChild == null) {
      return false;
    }
    final parentData = targetChild.parentData;
    if (parentData is! SliverMultiBoxAdaptorParentData) {
      return false;
    }
    final targetChildLayoutOffset = parentData.layoutOffset ?? 0;
    return targetChildLayoutOffset < listViewBottomOffset;
  }
}
