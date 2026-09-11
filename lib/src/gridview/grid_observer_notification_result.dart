/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/LinXunFeng/flutter_scrollview_observer
 * @Date: 2023-08-12 20:08:21
 */

import 'package:scrollview_observer/src/common/models/observer_handle_contexts_result_model.dart';
import 'package:scrollview_observer/src/common/observer_notification_result.dart';
import 'package:scrollview_observer/src/gridview/models/gridview_observe_model.dart';

class GridViewOnceObserveNotificationResult
    extends
        CommonOnceObserveNotificationResult<
          GridViewObserveModel,
          ObserverHandleContextsResultModel<GridViewObserveModel>
        > {
  GridViewOnceObserveNotificationResult({
    required super.type,
    required ObserverHandleContextsResultModel<GridViewObserveModel>
    observeResult,
  }) : super(
         observeResult: observeResult.changeResultModel,
         observeAllResult: observeResult.changeResultMap,
       );
}
