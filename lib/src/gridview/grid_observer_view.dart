import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:scrollview_observer/src/common/observer_widget.dart';
import 'package:scrollview_observer/src/notification.dart';

import 'grid_observer_controller.dart';
import 'models/gridview_observe_displaying_child_model.dart';
import 'models/gridview_observe_model.dart';

class GridViewObserver extends ObserverWidget<GridObserverController,
    GridViewObserveModel, GridViewOnceObserveNotification, RenderSliverGrid> {
  /// The callback of getting all sliverGrid's buildContext.
  final List<BuildContext> Function()? sliverGridContexts;

  final GridObserverController? controller;

  const GridViewObserver({
    Key? key,
    required Widget child,
    this.sliverGridContexts,
    this.controller,
    Function(Map<BuildContext, GridViewObserveModel>)? onObserveAll,
    Function(GridViewObserveModel)? onObserve,
    double leadingOffset = 0,
    double Function()? dynamicLeadingOffset,
    double toNextOverPercent = 1,
  }) : super(
          key: key,
          child: child,
          sliverContexts: sliverGridContexts,
          sliverController: controller,
          onObserveAll: onObserveAll,
          onObserve: onObserve,
          leadingOffset: leadingOffset,
          dynamicLeadingOffset: dynamicLeadingOffset,
          toNextOverPercent: toNextOverPercent,
        );

  @override
  State<GridViewObserver> createState() => _GridViewObserverState();
}

class _GridViewObserverState extends ObserverWidgetState<
    GridObserverController,
    GridViewObserveModel,
    GridViewOnceObserveNotification,
    RenderSliverGrid,
    GridViewObserver> {
  @override
  GridViewObserveModel? handleObserve(BuildContext ctx) {
    final _obj = ctx.findRenderObject();
    if (_obj is! RenderSliverGrid) return null;
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
    var parentData = firstChild.parentData as SliverMultiBoxAdaptorParentData;
    var index = parentData.index ?? 0;

    // Find out the first child which is displaying
    var targetFirstChild = firstChild;
    var lastFirstGroupChildWidget = targetFirstChild;

    while (!isTargetFirstWidget(
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
        sliverGrid: _obj,
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
        sliverGrid: _obj,
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
