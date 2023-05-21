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

import 'list_observer_controller.dart';
import 'models/listview_observe_model.dart';

class ListViewObserver extends ObserverWidget<ListObserverController,
    ListViewObserveModel, ListViewOnceObserveNotification> {
  /// The callback of getting all sliverList's buildContext.
  final List<BuildContext> Function()? sliverListContexts;

  final ListObserverController? controller;

  const ListViewObserver({
    Key? key,
    required Widget child,
    this.controller,
    this.sliverListContexts,
    Function(Map<BuildContext, ListViewObserveModel>)? onObserveAll,
    Function(ListViewObserveModel)? onObserve,
    double leadingOffset = 0,
    double Function()? dynamicLeadingOffset,
    double toNextOverPercent = 1,
    List<ObserverAutoTriggerObserveType>? autoTriggerObserveTypes,
    ObserverTriggerOnObserveType triggerOnObserveType =
        ObserverTriggerOnObserveType.displayingItemsChange,
    ListViewObserveModel? Function(BuildContext context)? customHandleObserve,
    bool Function(RenderObject?)? customTargetRenderSliverType,
  }) : super(
          key: key,
          child: child,
          sliverController: controller,
          sliverContexts: sliverListContexts,
          onObserveAll: onObserveAll,
          onObserve: onObserve,
          leadingOffset: leadingOffset,
          dynamicLeadingOffset: dynamicLeadingOffset,
          toNextOverPercent: toNextOverPercent,
          autoTriggerObserveTypes: autoTriggerObserveTypes,
          triggerOnObserveType: triggerOnObserveType,
          customHandleObserve: customHandleObserve,
          customTargetRenderSliverType: customTargetRenderSliverType,
        );

  @override
  State<ListViewObserver> createState() => ListViewObserverState();
}

class ListViewObserverState extends ObserverWidgetState<ListObserverController,
    ListViewObserveModel, ListViewOnceObserveNotification, ListViewObserver> {
  @override
  ListViewObserveModel? handleObserve(BuildContext ctx) {
    if (widget.customHandleObserve != null) {
      return widget.customHandleObserve?.call(ctx);
    }
    return ObserverCore.handleListObserve(
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
    return obj is RenderSliverList || obj is RenderSliverFixedExtentList;
  }
}
