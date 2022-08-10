/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Reop: https://github.com/LinXunFeng/flutter_scrollview_observer
 * @Date: 2022-08-08 00:20:03
 */
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:scrollview_observer/src/common/observer_widget.dart';

import 'list_observer_controller.dart';
import 'list_observer_mix.dart';
import 'models/listview_observe_model.dart';
import '../notification.dart';

class ListViewObserver extends ObserverWidget<ListObserverController,
    ListViewObserveModel, ListViewOnceObserveNotification, RenderSliverList> {
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
        );

  @override
  State<ListViewObserver> createState() => ListViewObserverState();
}

class ListViewObserverState extends ObserverWidgetState<
        ListObserverController,
        ListViewObserveModel,
        ListViewOnceObserveNotification,
        RenderSliverList,
        ListViewObserver>
    with
        ListObserverMix<
            ListObserverController,
            ListViewObserveModel,
            ListViewOnceObserveNotification,
            RenderSliverList,
            ListViewObserver> {
  @override
  ListViewObserveModel? handleObserve(BuildContext ctx) {
    return handleListObserve(ctx);
  }
}
