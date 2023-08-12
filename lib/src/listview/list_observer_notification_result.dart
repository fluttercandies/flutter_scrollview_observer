/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/LinXunFeng/flutter_scrollview_observer
 * @Date: 2023-08-12 20:07:18
 */

import 'package:scrollview_observer/src/common/models/observer_handle_contexts_result_model.dart';
import 'package:scrollview_observer/src/common/observer_notification_result.dart';
import 'package:scrollview_observer/src/common/typedefs.dart';
import 'package:scrollview_observer/src/listview/models/listview_observe_model.dart';

class ListViewOnceObserveNotificationResult
    extends CommonOnceObserveNotificationResult<ListViewObserveModel,
        ObserverHandleContextsResultModel<ListViewObserveModel>> {
  ListViewOnceObserveNotificationResult({
    required ObserverWidgetObserveResultType type,
    required ObserverHandleContextsResultModel<ListViewObserveModel>
        observeResult,
  }) : super(
          type: type,
          observeResult: observeResult.changeResultModel,
          observeAllResult: observeResult.changeResultMap,
        );
}
