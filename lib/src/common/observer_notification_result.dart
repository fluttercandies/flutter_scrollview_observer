/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/LinXunFeng/flutter_scrollview_observer
 * @Date: 2023-08-12 20:09:46
 */

import 'package:flutter/material.dart';
import 'package:scrollview_observer/src/common/models/observe_model.dart';
import 'package:scrollview_observer/src/common/models/observer_handle_contexts_result_model.dart';
import 'package:scrollview_observer/src/common/typedefs.dart';

class CommonOnceObserveNotificationResult<M extends ObserveModel,
    R extends ObserverHandleContextsResultModel<M>> {
  bool get isSuccess => ObserverWidgetObserveResultType.success == type;

  /// Observation result type.
  final ObserverWidgetObserveResultType type;

  /// Observation result for first sliver.
  /// Corresponding to [onObserve] in [ObserverWidget].
  final M? observeResult;

  /// Observation result map.
  /// Corresponding to [onObserveAll] in [ObserverWidget].
  final Map<BuildContext, M> observeAllResult;

  CommonOnceObserveNotificationResult({
    required this.type,
    required this.observeResult,
    required this.observeAllResult,
  });
}
