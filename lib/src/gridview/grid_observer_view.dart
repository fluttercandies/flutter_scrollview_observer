/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/LinXunFeng/flutter_scrollview_observer
 * @Date: 2022-08-08 00:20:03
 */
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:scrollview_observer/src/common/observer_widget.dart';
import 'package:scrollview_observer/src/common/observer_typedef.dart';
import 'package:scrollview_observer/src/notification.dart';
import 'package:scrollview_observer/src/observer_core.dart';

import 'grid_observer_controller.dart';
import 'models/gridview_observe_model.dart';

class GridViewObserver extends ObserverWidget<GridObserverController,
    GridViewObserveModel, GridViewOnceObserveNotification> {
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
    ScrollNotificationPredicate? scrollNotificationPredicate,
    List<ObserverAutoTriggerObserveType>? autoTriggerObserveTypes,
    ObserverTriggerOnObserveType triggerOnObserveType =
        ObserverTriggerOnObserveType.displayingItemsChange,
    GridViewObserveModel? Function(BuildContext context)? customHandleObserve,
    bool Function(RenderObject?)? customTargetRenderSliverType,
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
          scrollNotificationPredicate: scrollNotificationPredicate,
          autoTriggerObserveTypes: autoTriggerObserveTypes,
          triggerOnObserveType: triggerOnObserveType,
          customHandleObserve: customHandleObserve,
          customTargetRenderSliverType: customTargetRenderSliverType,
        );

  @override
  State<GridViewObserver> createState() => GridViewObserverState();
}

class GridViewObserverState extends ObserverWidgetState<GridObserverController,
    GridViewObserveModel, GridViewOnceObserveNotification, GridViewObserver> {
  @override
  GridViewObserveModel? handleObserve(BuildContext ctx) {
    if (widget.customHandleObserve != null) {
      return widget.customHandleObserve?.call(ctx);
    }
    return ObserverCore.handleGridObserve(
      context: ctx,
      fetchLeadingOffset: fetchLeadingOffset,
      toNextOverPercent: widget.toNextOverPercent,
    );
  }

  /// Determine whether it is the type of the target sliver.
  @override
  bool isTargetSliverContextType(RenderObject? obj) {
    if (widget.customTargetRenderSliverType != null) {
      return widget.customTargetRenderSliverType!.call(obj);
    }
    return obj is RenderSliverGrid;
  }
}
