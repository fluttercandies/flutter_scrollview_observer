/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/LinXunFeng/flutter_scrollview_observer
 * @Date: 2022-08-08 00:20:03
 */
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:scrollview_observer/src/common/observer_typedef.dart';
import 'package:scrollview_observer/src/common/models/observe_model.dart';
import 'package:scrollview_observer/src/common/observer_widget.dart';
import 'package:scrollview_observer/src/gridview/grid_observer_mix.dart';
import 'package:scrollview_observer/src/listview/list_observer_mix.dart';
import 'package:scrollview_observer/src/notification.dart';

import 'sliver_observer_controller.dart';

class SliverViewObserver extends ObserverWidget<SliverObserverController,
    ObserveModel, ScrollViewOnceObserveNotification, RenderSliverList> {
  /// The callback of getting all sliverList's buildContext.
  final List<BuildContext> Function()? sliverListContexts;

  final SliverObserverController? controller;

  const SliverViewObserver({
    Key? key,
    required Widget child,
    this.controller,
    this.sliverListContexts,
    Function(Map<BuildContext, ObserveModel>)? onObserveAll,
    Function(ObserveModel)? onObserve,
    double leadingOffset = 0,
    double Function()? dynamicLeadingOffset,
    double toNextOverPercent = 1,
    List<ObserverAutoTriggerObserveType>? autoTriggerObserveTypes,
    ObserverTriggerOnObserveType triggerOnObserveType =
        ObserverTriggerOnObserveType.displayingItemsChange,
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
        );

  @override
  State<SliverViewObserver> createState() => MixViewObserverState();
}

class MixViewObserverState extends ObserverWidgetState<
    SliverObserverController,
    ObserveModel,
    ScrollViewOnceObserveNotification,
    RenderSliverList,
    SliverViewObserver> with ListObserverMix, GridObserverMix {
  @override
  ObserveModel? handleObserve(BuildContext ctx) {
    final _obj = ctx.findRenderObject();
    if (_obj is RenderSliverList) {
      return handleListObserve(ctx);
    } else if (_obj is RenderSliverGrid) {
      return handleGridObserve(ctx);
    }
    return null;
  }
}
