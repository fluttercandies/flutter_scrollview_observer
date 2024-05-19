/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/LinXunFeng/flutter_scrollview_observer
 * @Date: 2023-08-12 20:13:21
 */

import 'package:scrollview_observer/src/common/models/observe_model.dart';
import 'package:scrollview_observer/src/common/observer_notification_result.dart';
import 'package:scrollview_observer/src/common/typedefs.dart';
import 'package:scrollview_observer/src/sliver/models/sliver_observer_observe_result_model.dart';
import 'package:scrollview_observer/src/sliver/models/sliver_viewport_observe_model.dart';

class ScrollViewOnceObserveNotificationResult
    extends CommonOnceObserveNotificationResult<ObserveModel,
        SliverObserverHandleContextsResultModel<ObserveModel>> {
  ScrollViewOnceObserveNotificationResult({
    required ObserverWidgetObserveResultType type,
    required SliverObserverHandleContextsResultModel<ObserveModel>
        observeResult,
  }) : super(
          type: type,
          observeResult: observeResult.changeResultModel,
          observeAllResult: observeResult.changeResultMap,
        ) {
    observeViewportResultModel = observeResult.observeViewportResultModel;
  }

  /// Getting all slivers those are displayed in viewport.
  ///
  /// Corresponding to [onObserveViewport] in [SliverViewObserver].
  SliverViewportObserveModel? observeViewportResultModel;
}
