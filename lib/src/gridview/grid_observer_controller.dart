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

class GridObserverController extends ObserverController
    with
        ObserverControllerForInfo,
        ObserverControllerForScroll,
        ObserverControllerForNotification<
            GridViewObserveModel,
            ObserverHandleContextsResultModel<GridViewObserveModel>,
            GridViewOnceObserveNotificationResult> {
  GridObserverController({
    ScrollController? controller,
  }) : super(controller: controller);

  /// Dispatch a [GridViewOnceObserveNotification]
  Future<GridViewOnceObserveNotificationResult> dispatchOnceObserve({
    BuildContext? sliverContext,
    bool isForce = false,
    bool isDependObserveCallback = true,
  }) {
    return innerDispatchOnceObserve(
      sliverContext: sliverContext,
      notification: GridViewOnceObserveNotification(
        isForce: isForce,
        isDependObserveCallback: isDependObserveCallback,
      ),
    );
  }

  /// Observe the child which is specified index in sliver.
  GridViewObserveDisplayingChildModel? observeItem({
    required int index,
    BuildContext? sliverContext,
  }) {
    final model = findChildInfo(index: index, sliverContext: sliverContext);
    if (model == null) return null;
    return GridViewObserveDisplayingChildModel(
      sliverGrid: model.sliver as RenderSliverGrid,
      viewport: model.viewport,
      index: model.index,
      renderObject: model.renderObject,
    );
  }

  /// Observe the first child in sliver.
  ///
  /// Note that the first child here is not the first child being displayed in
  /// sliver, and it may not be displayed.
  GridViewObserveDisplayingChildModel? observeFirstItem({
    BuildContext? sliverContext,
  }) {
    final model = findCurrentFirstChildInfo(sliverContext: sliverContext);
    if (model == null) return null;
    return GridViewObserveDisplayingChildModel(
      sliverGrid: model.sliver as RenderSliverGrid,
      viewport: model.viewport,
      index: model.index,
      renderObject: model.renderObject,
    );
  }

  /// Create a observation notification result.
  @override
  GridViewOnceObserveNotificationResult
      innerCreateOnceObserveNotificationResult({
    required ObserverWidgetObserveResultType resultType,
    required ObserverHandleContextsResultModel<GridViewObserveModel>?
        resultModel,
  }) {
    return GridViewOnceObserveNotificationResult(
      type: resultType,
      observeResult: resultModel ?? ObserverHandleContextsResultModel(),
    );
  }
}
