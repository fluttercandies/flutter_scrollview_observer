import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'models/listview_observe_model.dart';
import 'models/listview_observe_displaying_child_model.dart';
import '../notification.dart';

class ListViewObserver extends StatefulWidget {
  final Widget child;

  /// The callback of getting all sliverList's buildContext.
  final List<BuildContext> Function()? sliverListContexts;

  /// The callback of geting observed result map.
  final Function(Map<BuildContext, ListViewObserveModel>)? onObserveAll;

  /// The callback of geting observed result for first listView.
  final Function(ListViewObserveModel)? onObserve;

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

  const ListViewObserver({
    Key? key,
    required this.child,
    this.sliverListContexts,
    this.onObserveAll,
    this.onObserve,
    this.leadingOffset = 0,
    this.dynamicLeadingOffset,
    this.toNextOverPercent = 1,
  })  : assert(toNextOverPercent > 0 && toNextOverPercent <= 1),
        super(key: key);

  @override
  State<ListViewObserver> createState() => _ListViewObserverState();
}

class _ListViewObserverState extends State<ListViewObserver> {
  /// Target SliverList BuildContext
  List<BuildContext> targetSliverListContexts = [];

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
    final onObserve = widget.onObserve;
    final onObserveAll = widget.onObserveAll;
    if (onObserve == null && onObserveAll == null) return;

    List<BuildContext> ctxs = targetSliverListContexts;
    if (ctxs.isEmpty) {
      final sliverListContexts = widget.sliverListContexts;
      if (sliverListContexts != null) {
        ctxs = sliverListContexts();
      } else {
        List<BuildContext> _ctxs = [];
        void visitor(Element element) {
          if (element.renderObject is RenderSliverList) {
            /// Find the target sliverList context
            _ctxs.add(element);
            return;
          }
          element.visitChildren(visitor);
        }

        context.visitChildElements(visitor);
        ctxs = _ctxs;
      }
    }

    Map<BuildContext, ListViewObserveModel> resultMap = {};
    Map<BuildContext, ListViewObserveModel> changeResultMap = {};
    ListViewObserveModel? changeResultModel;
    for (var i = 0; i < ctxs.length; i++) {
      final ctx = ctxs[i];
      final targetObserveModel = _handleObserve(ctx);
      if (targetObserveModel == null) continue;
      resultMap[ctx] = targetObserveModel;

      final lastResultModel = lastResultMap[ctx];
      if (lastResultModel == null) {
        changeResultMap[ctx] = targetObserveModel;
      } else if (lastResultModel != targetObserveModel) {
        changeResultMap[ctx] = targetObserveModel;
      }

      // Geting observed result for first listView
      if (i == 0 && changeResultMap[ctx] != null) {
        changeResultModel = changeResultMap[ctx];
      }
    }

    lastResultMap = resultMap;

    if (onObserve != null && changeResultModel != null) {
      onObserve(changeResultModel);
    }

    if (onObserveAll != null && changeResultMap.isNotEmpty) {
      onObserveAll(changeResultMap);
    }
  }

  ListViewObserveModel? _handleObserve(BuildContext ctx) {
    final _obj = ctx.findRenderObject();
    if (_obj is! RenderSliverList) return null;
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

    // find out the first child which is displaying
    var targetFirstChild = firstChild;

    while (!_isTargetFirstWidget(
      listViewOffset: listViewOffset,
      scrollDirection: scrollDirection,
      targetFirstChild: targetFirstChild,
    )) {
      index = index + 1;
      var nextChild = _obj.childAfter(targetFirstChild);
      if (nextChild == null) break;

      if (nextChild is! RenderIndexedSemantics) {
        // it is separator
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

    // find the remaining children that are being displayed
    final listViewBottomOffset =
        rawListViewOffset + _obj.constraints.remainingPaintExtent;
    var displayingChild = _obj.childAfter(targetFirstChild);
    while (_isDisplayingChild(
      targetChild: displayingChild,
      listViewBottomOffset: listViewBottomOffset,
    )) {
      if (displayingChild == null) {
        break;
      }
      if (displayingChild is! RenderIndexedSemantics) {
        // it is separator
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
