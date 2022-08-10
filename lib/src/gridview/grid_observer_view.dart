/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Reop: https://github.com/LinXunFeng/flutter_scrollview_observer
 * @Date: 2022-08-08 00:20:03
 */
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:scrollview_observer/src/common/observer_widget.dart';
import 'package:scrollview_observer/src/notification.dart';

import 'grid_observer_controller.dart';
import 'grid_observer_mix.dart';
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
  State<GridViewObserver> createState() => GridViewObserverState();
}

class GridViewObserverState extends ObserverWidgetState<
        GridObserverController,
        GridViewObserveModel,
        GridViewOnceObserveNotification,
        RenderSliverGrid,
        GridViewObserver>
    with
        GridObserverMix<
            GridObserverController,
            GridViewObserveModel,
            GridViewOnceObserveNotification,
            RenderSliverGrid,
            GridViewObserver> {
  @override
  GridViewObserveModel? handleObserve(BuildContext ctx) {
    return handleGridObserve(ctx);
  }
}
