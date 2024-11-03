/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/LinXunFeng/flutter_scrollview_observer
 * @Date: 2022-08-08 00:20:03
 */
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:scrollview_observer/src/common/observer_typedef.dart';
import 'package:scrollview_observer/src/common/observer_widget.dart';
import 'package:scrollview_observer/src/listview/models/listview_observe_model.dart';
import 'package:scrollview_observer/src/notification.dart';
import 'package:scrollview_observer/src/observer_core.dart';

import 'list_observer_controller.dart';

class ListViewObserver extends ObserverWidget<ListObserverController,
    ListViewObserveModel, ListViewOnceObserveNotification> {
  /// The callback of getting all sliverList's buildContext.
  final List<BuildContext> Function()? sliverListContexts;

  final ListObserverController? controller;

  const ListViewObserver({
    Key? key,
    required Widget child,
    String? tag,
    this.controller,
    this.sliverListContexts,
    OnObserveAllCallback<ListViewObserveModel>? onObserveAll,
    OnObserveCallback<ListViewObserveModel>? onObserve,
    double leadingOffset = 0,
    double Function()? dynamicLeadingOffset,
    double toNextOverPercent = 1,
    ScrollNotificationPredicate? scrollNotificationPredicate,
    List<ObserverAutoTriggerObserveType>? autoTriggerObserveTypes,
    ObserverTriggerOnObserveType triggerOnObserveType =
        ObserverTriggerOnObserveType.displayingItemsChange,
    ListViewObserveModel? Function(BuildContext context)? customHandleObserve,
    bool Function(RenderObject?)? customTargetRenderSliverType,
  }) : super(
          key: key,
          child: child,
          tag: tag,
          sliverController: controller,
          sliverContexts: sliverListContexts,
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
  State<ListViewObserver> createState() => ListViewObserverState();

  /// Returning the closest instance of this class that encloses the given
  /// context.
  ///
  /// If you give a tag, it will give priority find the corresponding instance
  /// of this class with the given tag and return it.
  ///
  /// If there is no [ListViewObserver] widget, then null is returned.
  ///
  /// Calling this method will create a dependency on the closest
  /// [ListViewObserver] in the [context], if there is one.
  ///
  /// See also:
  ///
  /// * [ListViewObserver.of], which is similar to this method, but asserts if no
  ///   [ListViewObserver] instance is found.
  static ListViewObserverState? maybeOf(
    BuildContext context, {
    String? tag,
  }) {
    final _state = ObserverWidget.maybeOf<
        ListObserverController,
        ListViewObserveModel,
        ListViewOnceObserveNotification,
        ListViewObserver>(
      context,
      tag: tag,
    );
    if (_state is! ListViewObserverState) return null;
    return _state;
  }

  /// Returning the closest instance of this class that encloses the given
  /// context.
  ///
  /// If you give a tag, it will give priority find the corresponding instance
  /// of this class with the given tag and return it.
  ///
  /// If no instance is found, this method will assert in debug mode, and throw
  /// an exception in release mode.
  ///
  /// Calling this method will create a dependency on the closest
  /// [ObserverWidget] in the [context].
  ///
  /// See also:
  ///
  /// * [ObserverWidget.maybeOf], which is similar to this method, but returns
  ///   null if no [ObserverWidget] instance is found.
  static ListViewObserverState of(
    BuildContext context, {
    String? tag,
  }) {
    final _state = ObserverWidget.of<
        ListObserverController,
        ListViewObserveModel,
        ListViewOnceObserveNotification,
        ListViewObserver>(
      context,
      tag: tag,
    );
    return _state as ListViewObserverState;
  }

  /// Determine whether the [obj] is a supported RenderSliver type.
  static bool isSupportRenderSliverType(RenderObject? obj) {
    if (obj == null) return false;
    if (obj is RenderSliverList || obj is RenderSliverFixedExtentList) {
      return true;
    }
    final objRuntimeTypeStr = obj.runtimeType.toString();
    final types = [
      // New type added in flutter 3.16.0.
      // https://github.com/fluttercandies/flutter_scrollview_observer/issues/74
      'RenderSliverVariedExtentList',
    ];
    return types.contains(objRuntimeTypeStr);
  }
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
    return ListViewObserver.isSupportRenderSliverType(obj);
  }
}
