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
import 'package:scrollview_observer/src/notification.dart';
import 'package:scrollview_observer/src/observer_core.dart';
import 'package:scrollview_observer/src/sliver/models/sliver_observer_observe_result_model.dart';
import 'package:scrollview_observer/src/sliver/models/sliver_viewport_observe_displaying_child_model.dart';
import 'package:scrollview_observer/src/utils/observer_utils.dart';

import 'models/sliver_viewport_observe_model.dart';
import 'sliver_observer_controller.dart';

class SliverViewObserver extends ObserverWidget<SliverObserverController,
    ObserveModel, ScrollViewOnceObserveNotification> {
  /// The callback of getting all slivers those are displayed in viewport.
  final Function(SliverViewportObserveModel)? onObserveViewport;

  /// It's used to handle the observation logic for other types of Sliver
  /// besides [RenderSliverList], [RenderSliverFixedExtentList] and
  /// [RenderSliverGrid].
  final ObserveModel? Function(BuildContext context)? extendedHandleObserve;

  final SliverObserverController? controller;

  const SliverViewObserver({
    Key? key,
    required Widget child,
    this.controller,
    @Deprecated('It will be removed in version 2, please use [sliverContexts] instead')
        List<BuildContext> Function()? sliverListContexts,
    List<BuildContext> Function()? sliverContexts,
    Function(Map<BuildContext, ObserveModel>)? onObserveAll,
    Function(ObserveModel)? onObserve,
    this.onObserveViewport,
    double leadingOffset = 0,
    double Function()? dynamicLeadingOffset,
    double toNextOverPercent = 1,
    List<ObserverAutoTriggerObserveType>? autoTriggerObserveTypes,
    ObserverTriggerOnObserveType triggerOnObserveType =
        ObserverTriggerOnObserveType.displayingItemsChange,
    ObserveModel? Function(BuildContext context)? customHandleObserve,
    this.extendedHandleObserve,
  }) : super(
          key: key,
          child: child,
          sliverController: controller,
          sliverContexts: sliverContexts ?? sliverListContexts,
          onObserveAll: onObserveAll,
          onObserve: onObserve,
          leadingOffset: leadingOffset,
          dynamicLeadingOffset: dynamicLeadingOffset,
          toNextOverPercent: toNextOverPercent,
          autoTriggerObserveTypes: autoTriggerObserveTypes,
          triggerOnObserveType: triggerOnObserveType,
          customHandleObserve: customHandleObserve,
        );

  @override
  State<SliverViewObserver> createState() => MixViewObserverState();
}

class MixViewObserverState extends ObserverWidgetState<SliverObserverController,
    ObserveModel, ScrollViewOnceObserveNotification, SliverViewObserver> {
  /// The last viewport observation result.
  SliverViewportObserveModel? lastViewportObserveResultModel;

  @override
  SliverObserverHandleContextsResultModel<ObserveModel>? handleContexts({
    bool isForceObserve = false,
    bool isFromObserveNotification = false,
    bool isDependObserveCallback = true,
  }) {
    // Viewport
    final observeViewportResult = handleObserveViewport(
      isForceObserve: isForceObserve,
      isDependObserveCallback: isDependObserveCallback,
    );

    // Slivers（SliverList, GridView etc.）
    final handleContextsResult = super.handleContexts(
      isForceObserve: isForceObserve,
      isFromObserveNotification: isFromObserveNotification,
      isDependObserveCallback: isDependObserveCallback,
    );

    if (observeViewportResult == null && handleContextsResult == null) {
      return null;
    }
    return SliverObserverHandleContextsResultModel(
      changeResultModel: handleContextsResult?.changeResultModel,
      changeResultMap: handleContextsResult?.changeResultMap ?? {},
      observeViewportResultModel: observeViewportResult,
    );
  }

  @override
  ObserveModel? handleObserve(BuildContext ctx) {
    if (widget.customHandleObserve != null) {
      return widget.customHandleObserve?.call(ctx);
    }
    final _obj = ObserverUtils.findRenderObject(ctx);
    if (_obj is RenderSliverList || _obj is RenderSliverFixedExtentList) {
      return ObserverCore.handleListObserve(
        context: ctx,
        fetchLeadingOffset: fetchLeadingOffset,
        toNextOverPercent: widget.toNextOverPercent,
      );
    } else if (_obj is RenderSliverGrid) {
      return ObserverCore.handleGridObserve(
        context: ctx,
        fetchLeadingOffset: fetchLeadingOffset,
        toNextOverPercent: widget.toNextOverPercent,
      );
    }
    return widget.extendedHandleObserve?.call(ctx);
  }

  /// To observe the viewport.
  SliverViewportObserveModel? handleObserveViewport({
    bool isForceObserve = false,
    bool isDependObserveCallback = true,
  }) {
    final onObserveViewport = widget.onObserveViewport;
    if (isDependObserveCallback && onObserveViewport == null) return null;

    final isHandlingScroll =
        widget.sliverController?.innerIsHandlingScroll ?? false;
    if (isHandlingScroll) return null;

    final ctxs = fetchTargetSliverContexts();
    final objList = ctxs.map((e) => ObserverUtils.findRenderObject(e)).toList();
    if (objList.isEmpty) return null;
    final firstObj = objList.first;
    if (firstObj == null) return null;
    final viewport = ObserverUtils.findViewport(firstObj);
    if (viewport == null) return null;
    final viewportOffset = viewport.offset;
    if (viewportOffset is! ScrollPosition) return null;

    var targetChild = viewport.firstChild;
    if (targetChild == null) return null;
    var offset = widget.leadingOffset;
    if (widget.dynamicLeadingOffset != null) {
      offset = widget.dynamicLeadingOffset!();
    }
    final pixels = viewportOffset.pixels;
    final startCalcPixels = pixels + offset;

    int indexOfTargetChild = objList.indexOf(targetChild);

    // Find out the first sliver which is displayed in viewport.
    final dimension = viewportOffset.viewportDimension;
    final viewportBottomOffset = pixels + dimension;

    while (!ObserverUtils.isValidListIndex(indexOfTargetChild) ||
        !ObserverUtils.isDisplayingSliverInViewport(
          sliver: targetChild,
          viewportPixels: startCalcPixels,
          viewportBottomOffset: viewportBottomOffset,
        )) {
      if (targetChild == null) break;
      final nextChild = viewport.childAfter(targetChild);
      if (nextChild == null) break;
      targetChild = nextChild;
      indexOfTargetChild = objList.indexOf(targetChild);
    }

    if (targetChild == null ||
        !ObserverUtils.isValidListIndex(indexOfTargetChild)) return null;
    final targetCtx = ctxs[indexOfTargetChild];
    final firstChild = SliverViewportObserveDisplayingChildModel(
      sliverContext: targetCtx,
      sliver: targetChild,
    );

    List<SliverViewportObserveDisplayingChildModel> displayingChildModelList = [
      firstChild
    ];

    // Find the remaining children that are being displayed.
    targetChild = viewport.childAfter(targetChild);
    while (targetChild != null) {
      // The current targetChild is not displayed, so the later children don't
      // need to be check
      if (!ObserverUtils.isDisplayingSliverInViewport(
        sliver: targetChild,
        viewportPixels: startCalcPixels,
        viewportBottomOffset: viewportBottomOffset,
      )) break;

      indexOfTargetChild = objList.indexOf(targetChild);
      if (ObserverUtils.isValidListIndex(indexOfTargetChild)) {
        // The current targetChild is target.
        final context = ctxs[indexOfTargetChild];
        displayingChildModelList.add(SliverViewportObserveDisplayingChildModel(
          sliverContext: context,
          sliver: targetChild,
        ));
      }
      // continue to check next child.
      targetChild = viewport.childAfter(targetChild);
    }
    var model = SliverViewportObserveModel(
      viewport: viewport,
      firstChild: firstChild,
      displayingChildModelList: displayingChildModelList,
    );
    bool canReturnResult = false;
    if (isForceObserve ||
        widget.triggerOnObserveType == ObserverTriggerOnObserveType.directly) {
      canReturnResult = true;
    } else if (model != lastViewportObserveResultModel) {
      canReturnResult = true;
    }
    if (canReturnResult &&
        isDependObserveCallback &&
        onObserveViewport != null) {
      onObserveViewport(model);
    }

    // Record it for the next comparison.
    lastViewportObserveResultModel = model;

    return canReturnResult ? model : null;
  }
}
