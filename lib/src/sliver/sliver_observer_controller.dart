/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/LinXunFeng/flutter_scrollview_observer
 * @Date: 2022-08-08 00:20:03
 */
import 'package:flutter/material.dart';
import 'package:scrollview_observer/scrollview_observer.dart';
import 'package:scrollview_observer/src/common/observer_controller.dart';
import 'package:scrollview_observer/src/common/typedefs.dart';
import 'package:scrollview_observer/src/sliver/models/sliver_observer_observe_result_model.dart';

class SliverObserverController extends ObserverController
    with
        ObserverControllerForInfo,
        ObserverControllerForScroll,
        ObserverControllerForNotification<
            ObserveModel,
            SliverObserverHandleContextsResultModel<ObserveModel>,
            ScrollViewOnceObserveNotificationResult> {
  SliverObserverController({
    ScrollController? controller,
  }) : super(controller: controller);

  /// Dispatch a [ScrollViewOnceObserveNotification]
  Future<ScrollViewOnceObserveNotificationResult> dispatchOnceObserve({
    required BuildContext sliverContext,
    bool isForce = false,
    bool isDependObserveCallback = true,
  }) {
    return innerDispatchOnceObserve(
      sliverContext: sliverContext,
      notification: ScrollViewOnceObserveNotification(
        isForce: isForce,
        isDependObserveCallback: isDependObserveCallback,
      ),
    );
  }

  /// Create a observation notification result.
  @override
  ScrollViewOnceObserveNotificationResult
      innerCreateOnceObserveNotificationResult({
    required ObserverWidgetObserveResultType resultType,
    required SliverObserverHandleContextsResultModel<ObserveModel>? resultModel,
  }) {
    return ScrollViewOnceObserveNotificationResult(
      type: resultType,
      observeResult: resultModel ?? SliverObserverHandleContextsResultModel(),
    );
  }
}
