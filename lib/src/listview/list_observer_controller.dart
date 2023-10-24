/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/LinXunFeng/flutter_scrollview_observer
 * @Date: 2022-07-20 00:32:40
 */
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:scrollview_observer/scrollview_observer.dart';
import 'package:scrollview_observer/src/common/models/observer_handle_contexts_result_model.dart';
import 'package:scrollview_observer/src/common/observer_controller.dart';
import 'package:scrollview_observer/src/common/typedefs.dart';

class ListObserverController extends ObserverController
    with
        ObserverControllerForInfo,
        ObserverControllerForScroll,
        ObserverControllerForNotification<
            ListViewObserveModel,
            ObserverHandleContextsResultModel<ListViewObserveModel>,
            ListViewOnceObserveNotificationResult> {
  ListObserverController({
    ScrollController? controller,
  }) : super(controller: controller);

  /// Dispatch a [ListViewOnceObserveNotification]
  Future<ListViewOnceObserveNotificationResult> dispatchOnceObserve({
    BuildContext? sliverContext,
    bool isForce = false,
    bool isDependObserveCallback = true,
  }) {
    return innerDispatchOnceObserve(
      sliverContext: sliverContext,
      notification: ListViewOnceObserveNotification(
        isForce: isForce,
        isDependObserveCallback: isDependObserveCallback,
      ),
    );
  }

  /// Observe the child which is specified index in sliver.
  ListViewObserveDisplayingChildModel? observeItem({
    required int index,
    BuildContext? sliverContext,
  }) {
    final model = findChildInfo(index: index, sliverContext: sliverContext);
    if (model == null) return null;
    return ListViewObserveDisplayingChildModel(
      sliverList: model.sliver as RenderSliverMultiBoxAdaptor,
      viewport: model.viewport,
      index: model.index,
      renderObject: model.renderObject,
    );
  }

  /// Observe the first child in sliver.
  ///
  /// Note that the first child here is not the first child being displayed in
  /// sliver, and it may not be displayed.
  ListViewObserveDisplayingChildModel? observeFirstItem({
    BuildContext? sliverContext,
  }) {
    final model = findCurrentFirstChildInfo(sliverContext: sliverContext);
    if (model == null) return null;
    return ListViewObserveDisplayingChildModel(
      sliverList: model.sliver as RenderSliverMultiBoxAdaptor,
      viewport: model.viewport,
      index: model.index,
      renderObject: model.renderObject,
    );
  }

  /// Create a observation notification result.
  @override
  ListViewOnceObserveNotificationResult
      innerCreateOnceObserveNotificationResult({
    required ObserverWidgetObserveResultType resultType,
    required ObserverHandleContextsResultModel<ListViewObserveModel>?
        resultModel,
  }) {
    return ListViewOnceObserveNotificationResult(
      type: resultType,
      observeResult: resultModel ?? ObserverHandleContextsResultModel(),
    );
  }

  /// Jump to the specified index position with animation.
  ///
  /// If the height of the child widget and the height of the separator are
  /// fixed, please pass the [isFixedHeight] parameter.
  ///
  /// The [alignment] specifies the desired position for the leading edge of the
  /// child widget. It must be a value in the range [0.0, 1.0].
  animateTo({
    required int index,
    required Duration duration,
    required Curve curve,
    EdgeInsets padding = EdgeInsets.zero,
    BuildContext? sliverContext,
    bool isFixedHeight = false,
    double alignment = 0,
    ObserverLocateIndexOffsetCallback? offset,
  }) async {
    await innerAnimateTo(
      index: index,
      duration: duration,
      curve: curve,
      padding: padding,
      sliverContext: sliverContext,
      isFixedHeight: isFixedHeight,
      alignment: alignment,
      offset: offset,
      renderSliverType: ObserverRenderSliverType.list,
    );
  }

  /// Jump to the specified index position without animation.
  ///
  /// If the height of the child widget and the height of the separator are
  /// fixed, please pass the [isFixedHeight] parameter.
  ///
  /// If you do not pass the [isFixedHeight] parameter, the package will
  /// automatically gradually scroll around the target location before
  /// locating, which will produce an animation.
  ///
  /// The [alignment] specifies the desired position for the leading edge of the
  /// child widget. It must be a value in the range [0.0, 1.0].
  jumpTo({
    required int index,
    BuildContext? sliverContext,
    bool isFixedHeight = false,
    double alignment = 0,
    EdgeInsets padding = EdgeInsets.zero,
    ObserverLocateIndexOffsetCallback? offset,
  }) async {
    await innerJumpTo(
      index: index,
      sliverContext: sliverContext,
      isFixedHeight: isFixedHeight,
      alignment: alignment,
      padding: padding,
      offset: offset,
      renderSliverType: ObserverRenderSliverType.list,
    );
  }
}
